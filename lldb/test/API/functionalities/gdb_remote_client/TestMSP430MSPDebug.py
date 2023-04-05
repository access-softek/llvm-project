import lldb
from lldbsuite.test.lldbtest import *
from lldbsuite.test.decorators import *
from lldbsuite.test.gdbclientutils import *
from lldbsuite.test.lldbgdbclient import GDBRemoteTestBase

class MyResponder(MockGDBServerResponder):
    def qSupported(self, client_supported):
        return "PacketSize=4000"

    def setBreakpoint(self, packet):
        return "OK"

    haltReasonIndex = 0
    def haltReason(self):
        self.haltReasonIndex += 1
        match self.haltReasonIndex:
            case 1:
                return "T0500:00050000;01:00000000;02:00000000;03:00000000;04:00000000;05:00000000;06:00000000;07:00000000;08:00000000;09:00000000;0a:00000000;0b:00000000;0c:00000000;0d:00000000;0e:00000000;0f:00000000;"
            case 2:
                return "T0500:10050000;01:baff0000;02:05000000;03:00000000;04:00000000;05:00000000;06:00000000;07:00000000;08:00000000;09:00000000;0a:00000000;0b:00000000;0c:00000000;0d:00000000;0e:00000000;0f:00000000;"
            case 3:
                return "T0500:16050000;01:baff0000;02:05000000;03:00000000;04:00000000;05:00000000;06:00000000;07:00000000;08:00000000;09:00000000;0a:00000000;0b:00000000;0c:00000000;0d:00000000;0e:00000000;0f:00000000;"

    def cont(self):
        return self.haltReason()

    readMemoryIndex = 0
    def readMemory(self, addr, length):
        self.readMemoryIndex += 1
        match self.readMemoryIndex:
            case 1:
                return "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff3140c0ff0c43b0121c05b01281010000b240d2043c051c423c0530413180020081430000b01210053150020030411c4330413c402a0030410c433041ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
            case 2:
                return "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff280500000a05ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0005"

class TestMSP430MSPDebug(GDBRemoteTestBase):

    @skipIfLLVMTargetMissing("MSP430")
    def test(self):
        """
        Test LLDB's MSP430 functionality.
        """
        target = self.createTarget("msp430.yaml")
        self.server.responder = MyResponder()

        if self.TraceOn():
            self.runCmd("log enable gdb-remote packets")
            self.addTearDownHook(
                lambda: self.runCmd("log disable gdb-remote packets"))

        process = self.connect(target)
        lldbutil.expect_state_changes(self, self.dbg.GetListener(), process,
                                      [lldb.eStateStopped])
        num_threads = len(process.threads)
        self.assertEqual(num_threads, 1, "Only one thread")
        thread = process.GetThreadAtIndex(0)

        # Test if a breakpoint can be set
        bp = target.BreakpointCreateByName("func")
        self.assertTrue(bp.IsValid())
        bp.SetEnabled(True)
        self.assertTrue(bp.IsEnabled())

        # Test if the breakpoint address is resolved correctly
        self.assertEqual(bp.GetNumLocations(), 1, "Only one location")
        bp_loc = bp.GetLocationAtIndex(0);
        self.assertTrue(bp_loc.GetAddress().GetLoadAddress(target) == 0x510,
            "Address of main")

        # Test if the process stops at the breakpoint
        process.Continue()
        self.assertStopReason(thread.GetStopReason(), lldb.eStopReasonBreakpoint, "Hit a breakpoint")

        # Test if thread can step a single instruction
        thread.StepInstruction(False)
        self.assertTrue(thread.GetFrameAtIndex(0).GetPCAddress().GetLoadAddress(target) == 0x516,
            "Address of the next instruction")

        # Test if registers are being set correctly
        registerSet = thread.GetFrameAtIndex(0).GetRegisters().GetValueAtIndex(0)
        reg_val_dict = {
             "pc": 0x0516,  "sp": 0xffba,  "r2": 0x0005,
             "r3": 0x0000,  "fp": 0x0000,  "r5": 0x0000,
             "r6": 0x0000,  "r7": 0x0000,  "r8": 0x0000,
             "r9": 0x0000, "r10": 0x0000, "r11": 0x0000,
            "r12": 0x0000, "r13": 0x0000, "r14": 0x0000,
            "r15": 0x0000
        }
        for reg in registerSet:
            self.assertEqual(reg.GetValueAsUnsigned(),
                             reg_val_dict[reg.GetName()])

        # Check if backtracing works:
        self.assertTrue(len(thread.frames) >= 3)
        crt0_addr = thread.GetFrameAtIndex(2).GetPCAddress().GetLoadAddress(target)
        self.assertEqual(crt0_addr, 0x50a)


