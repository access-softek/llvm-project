//===-- ABISysV_msp430.cpp --------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ABISysV_msp430.h"

#include "lldb/Utility/ConstString.h"
#include "lldb/Utility/DataExtractor.h"
#include "lldb/Utility/Log.h"
#include "lldb/Core/Module.h"
#include "lldb/Core/PluginManager.h"
#include "lldb/Utility/RegisterValue.h"
#include "lldb/Core/Value.h"
#include "lldb/Core/ValueObjectConstResult.h"
#include "lldb/Core/ValueObjectRegister.h"
#include "lldb/Core/ValueObjectMemory.h"
#include "lldb/Symbol/UnwindPlan.h"
#include "lldb/Target/Target.h"
#include "lldb/Target/Process.h"
#include "lldb/Target/RegisterContext.h"
#include "lldb/Target/StackFrame.h"
#include "lldb/Target/Thread.h"

#include "llvm/ADT/Triple.h"

#include "llvm/IR/DerivedTypes.h"

using namespace lldb;
using namespace lldb_private;

LLDB_PLUGIN_DEFINE(ABISysV_msp430)

static RegisterInfo g_register_infos[] =
{
    { "r0", "pc", 2, 0, eEncodingUint, eFormatAddressInfo, {  0,  0, LLDB_REGNUM_GENERIC_PC,  0,  0 }, nullptr, nullptr },
    { "r1", "sp", 2, 0, eEncodingUint, eFormatAddressInfo, {  1,  1, LLDB_REGNUM_GENERIC_SP,  1,  1 }, nullptr, nullptr },
    { "r2",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  2,  2, LLDB_INVALID_REGNUM,     2,  2 }, nullptr, nullptr },
    { "r3",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  3,  3, LLDB_INVALID_REGNUM,     3,  3 }, nullptr, nullptr },
    { "r4",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  4,  4, LLDB_INVALID_REGNUM,     4,  4 }, nullptr, nullptr },
    { "r5",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  5,  5, LLDB_INVALID_REGNUM,     5,  5 }, nullptr, nullptr },
    { "r6",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  6,  6, LLDB_INVALID_REGNUM,     6,  6 }, nullptr, nullptr },
    { "r7",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  7,  7, LLDB_INVALID_REGNUM,     7,  7 }, nullptr, nullptr },
    { "r8",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  8,  8, LLDB_INVALID_REGNUM,     8,  8 }, nullptr, nullptr },
    { "r9",   "", 2, 0, eEncodingUint, eFormatAddressInfo, {  9,  9, LLDB_INVALID_REGNUM,     9,  9 }, nullptr, nullptr },
    { "r10",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 10, 10, LLDB_INVALID_REGNUM,    10, 10 }, nullptr, nullptr },
    { "r11",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 11, 11, LLDB_INVALID_REGNUM,    11, 11 }, nullptr, nullptr },
    { "r12",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 12, 12, LLDB_INVALID_REGNUM,    12, 12 }, nullptr, nullptr },
    { "r13",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 13, 13, LLDB_INVALID_REGNUM,    13, 13 }, nullptr, nullptr },
    { "r14",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 14, 14, LLDB_INVALID_REGNUM,    14, 14 }, nullptr, nullptr },
    { "r15",  "", 2, 0, eEncodingUint, eFormatAddressInfo, { 15, 15, LLDB_INVALID_REGNUM,    15, 15 }, nullptr, nullptr }
};

static const uint32_t k_num_register_infos = sizeof(g_register_infos)/sizeof(RegisterInfo);
static bool g_register_info_names_constified = false;

const lldb_private::RegisterInfo *
ABISysV_msp430::GetRegisterInfoArray ( uint32_t &count )
{
    // Make the C-string names and alt_names for the register infos into const
    // C-string values by having the ConstString unique the names in the global
    // constant C-string pool.
    if (!g_register_info_names_constified)
    {
        g_register_info_names_constified = true;
        for (uint32_t i=0; i<k_num_register_infos; ++i)
        {
            if (g_register_infos[i].name)
                g_register_infos[i].name = ConstString(g_register_infos[i].name).GetCString();
            if (g_register_infos[i].alt_name)
                g_register_infos[i].alt_name = ConstString(g_register_infos[i].alt_name).GetCString();
        }
    }
    count = k_num_register_infos;
    return g_register_infos;
}

/*
    http://en.wikipedia.org/wiki/Red_zone_%28computing%29

    In computing, a red zone is a fixed size area in memory beyond the stack pointer that has not been
    "allocated". This region of memory is not to be modified by interrupt/exception/signal handlers.
    This allows the space to be used for temporary data without the extra overhead of modifying the
    stack pointer. The x86-64 ABI mandates a 128 byte red zone.[1] The OpenRISC toolchain assumes a
    128 byte red zone though it is not documented.
*/
size_t
ABISysV_msp430::GetRedZoneSize () const
{
    return 0;
}

//------------------------------------------------------------------
// Static Functions
//------------------------------------------------------------------
//ABISP
//ABISysV_msp430::CreateInstance ( const ArchSpec &arch )
//{
//    static ABISP g_abi_sp;
//    if (arch.GetTriple().getArch() == llvm::Triple::msp430)
//    {
//        if (!g_abi_sp)
//            g_abi_sp.reset (new ABISysV_msp430);
//        return g_abi_sp;
//    }
//    return ABISP();
//}

ABISP
ABISysV_msp430::CreateInstance(lldb::ProcessSP process_sp, const ArchSpec &arch) {
  if (arch.GetTriple().getArch() == llvm::Triple::msp430) {
    return ABISP(
        new ABISysV_msp430(std::move(process_sp), MakeMCRegisterInfo(arch)));
  }
  return ABISP();
}

bool
ABISysV_msp430::PrepareTrivialCall ( Thread &thread,
                                      lldb::addr_t  sp    , 
                                      lldb::addr_t  pc    , 
                                      lldb::addr_t  ra    , 
                                      llvm::ArrayRef<addr_t> args ) const
{
    // we don't use the traditional trivial call specialized for jit
    return false;
}

bool
ABISysV_msp430::GetArgumentValues ( Thread &thread, ValueList &values ) const
{
    return false;
}

Status
ABISysV_msp430::SetReturnValueObject ( lldb::StackFrameSP &frame_sp, lldb::ValueObjectSP &new_value_sp )
{
    Status error;
    return error;
}

ValueObjectSP
ABISysV_msp430::GetReturnValueObjectSimple ( Thread &thread, CompilerType &return_compiler_type ) const
{
    ValueObjectSP return_valobj_sp;
    return return_valobj_sp;
}

ValueObjectSP
ABISysV_msp430::GetReturnValueObjectImpl ( Thread &thread, CompilerType &return_compiler_type ) const
{
    ValueObjectSP return_valobj_sp;
    return return_valobj_sp;
}

// called when we are on the first instruction of a new function
bool
ABISysV_msp430::CreateFunctionEntryUnwindPlan ( UnwindPlan &unwind_plan )
{
    unwind_plan.Clear();
    unwind_plan.SetRegisterKind(eRegisterKindGeneric);

    uint32_t sp_reg_num = LLDB_REGNUM_GENERIC_SP;
    uint32_t pc_reg_num = LLDB_REGNUM_GENERIC_PC;

    UnwindPlan::RowSP row(new UnwindPlan::Row);

    row->GetCFAValue().SetIsRegisterPlusOffset (LLDB_REGNUM_GENERIC_SP, 0);

    row->SetRegisterLocationToAtCFAPlusOffset(pc_reg_num, 2, true);
    row->SetRegisterLocationToIsCFAPlusOffset(sp_reg_num, 0, true);
    unwind_plan.AppendRow(row);
    
    unwind_plan.SetSourceName("msp430 at-func-entry default");
    unwind_plan.SetSourcedFromCompiler(eLazyBoolNo);
    return true;
}

bool
ABISysV_msp430::CreateDefaultUnwindPlan ( UnwindPlan &unwind_plan )
{
    unwind_plan.Clear();
    unwind_plan.SetRegisterKind(eRegisterKindGeneric);

    uint32_t sp_reg_num = LLDB_REGNUM_GENERIC_SP;
    uint32_t pc_reg_num = LLDB_REGNUM_GENERIC_PC;

    UnwindPlan::RowSP row(new UnwindPlan::Row);

    row->GetCFAValue().SetIsRegisterPlusOffset (LLDB_REGNUM_GENERIC_SP, 0);

    row->SetRegisterLocationToAtCFAPlusOffset(pc_reg_num, 2, true);
    row->SetRegisterLocationToIsCFAPlusOffset(sp_reg_num, 0, true);

    unwind_plan.AppendRow(row);
    unwind_plan.SetSourceName("msp430 default unwind plan");
    unwind_plan.SetSourcedFromCompiler(eLazyBoolNo);
    unwind_plan.SetUnwindPlanValidAtAllInstructions(eLazyBoolNo);
    return true;
}

bool
ABISysV_msp430::RegisterIsVolatile ( const RegisterInfo *reg_info )
{
    return !RegisterIsCalleeSaved( reg_info );
}

bool
ABISysV_msp430::RegisterIsCalleeSaved ( const RegisterInfo *reg_info )
{
    int reg = ((reg_info->byte_offset) / 2);

    bool save  = (reg >= 4) && (reg <= 10);
    return save;
}

void
ABISysV_msp430::Initialize( void )
{    
    PluginManager::RegisterPlugin(GetPluginNameStatic(),
                                  "System V ABI for msp430 targets",
                                  CreateInstance);
}

void
ABISysV_msp430::Terminate( void )
{
    PluginManager::UnregisterPlugin(CreateInstance);
}

