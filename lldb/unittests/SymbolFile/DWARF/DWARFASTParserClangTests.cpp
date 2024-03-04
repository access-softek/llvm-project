//===-- DWARFASTParserClangTests.cpp --------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Plugins/SymbolFile/DWARF/DWARFASTParserClang.h"
#include "Plugins/SymbolFile/DWARF/DWARFCompileUnit.h"
#include "Plugins/SymbolFile/DWARF/DWARFDIE.h"
#include "TestingSupport/Symbol/ClangTestUtils.h"
#include "TestingSupport/Symbol/YAMLModuleTester.h"
#include "lldb/Core/Debugger.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::dwarf;

namespace {
static std::once_flag debugger_initialize_flag;

class DWARFASTParserClangTests : public testing::Test {
  void SetUp() override {
    std::call_once(debugger_initialize_flag,
                   []() { Debugger::Initialize(nullptr); });
  }
};

class DWARFASTParserClangStub : public DWARFASTParserClang {
public:
  using DWARFASTParserClang::DWARFASTParserClang;
  using DWARFASTParserClang::LinkDeclContextToDIE;

  std::vector<const clang::DeclContext *> GetDeclContextToDIEMapKeys() {
    std::vector<const clang::DeclContext *> keys;
    for (const auto &it : m_decl_ctx_to_die)
      keys.push_back(it.first);
    return keys;
  }
};
} // namespace

// If your implementation needs to dereference the dummy pointers we are
// defining here, causing this test to fail, feel free to delete it.
TEST_F(DWARFASTParserClangTests,
       EnsureAllDIEsInDeclContextHaveBeenParsedParsesOnlyMatchingEntries) {

  /// Auxiliary debug info.
  const char *yamldata = R"(
--- !ELF
FileHeader:
  Class:   ELFCLASS64
  Data:    ELFDATA2LSB
  Type:    ET_EXEC
  Machine: EM_386
DWARF:
  debug_abbrev:
    - Table:
        - Code:            0x00000001
          Tag:             DW_TAG_compile_unit
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_language
              Form:            DW_FORM_data2
        - Code:            0x00000002
          Tag:             DW_TAG_base_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_encoding
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_byte_size
              Form:            DW_FORM_data1
  debug_info:
    - Version:         4
      AddrSize:        8
      Entries:
        - AbbrCode:        0x00000001
          Values:
            - Value:           0x000000000000000C
        - AbbrCode:        0x00000002
          Values:
            - Value:           0x0000000000000007 # DW_ATE_unsigned
            - Value:           0x0000000000000004
        - AbbrCode:        0x00000002
          Values:
            - Value:           0x0000000000000007 # DW_ATE_unsigned
            - Value:           0x0000000000000008
        - AbbrCode:        0x00000002
          Values:
            - Value:           0x0000000000000005 # DW_ATE_signed
            - Value:           0x0000000000000008
        - AbbrCode:        0x00000002
          Values:
            - Value:           0x0000000000000008 # DW_ATE_unsigned_char
            - Value:           0x0000000000000001
        - AbbrCode:        0x00000000
)";

  YAMLModuleTester t(yamldata);
  ASSERT_TRUE((bool)t.GetDwarfUnit());

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();

  DWARFASTParserClangStub ast_parser(ast_ctx);

  DWARFUnit *unit = t.GetDwarfUnit();
  const DWARFDebugInfoEntry *die_first = unit->DIE().GetDIE();
  const DWARFDebugInfoEntry *die_child0 = die_first->GetFirstChild();
  const DWARFDebugInfoEntry *die_child1 = die_child0->GetSibling();
  const DWARFDebugInfoEntry *die_child2 = die_child1->GetSibling();
  const DWARFDebugInfoEntry *die_child3 = die_child2->GetSibling();
  std::vector<DWARFDIE> dies = {
      DWARFDIE(unit, die_child0), DWARFDIE(unit, die_child1),
      DWARFDIE(unit, die_child2), DWARFDIE(unit, die_child3)};
  std::vector<clang::DeclContext *> decl_ctxs = {
      (clang::DeclContext *)1LL, (clang::DeclContext *)2LL,
      (clang::DeclContext *)2LL, (clang::DeclContext *)3LL};
  for (int i = 0; i < 4; ++i)
    ast_parser.LinkDeclContextToDIE(decl_ctxs[i], dies[i]);
  ast_parser.EnsureAllDIEsInDeclContextHaveBeenParsed(
      CompilerDeclContext(nullptr, decl_ctxs[1]));

  EXPECT_THAT(ast_parser.GetDeclContextToDIEMapKeys(),
              testing::UnorderedElementsAre(decl_ctxs[0], decl_ctxs[3]));
}

TEST_F(DWARFASTParserClangTests, TestCallingConventionParsing) {
  // Tests parsing DW_AT_calling_convention values.

  // The DWARF below just declares a list of function types with
  // DW_AT_calling_convention on them.
  const char *yamldata = R"(
--- !ELF
FileHeader:
  Class:   ELFCLASS32
  Data:    ELFDATA2LSB
  Type:    ET_EXEC
  Machine: EM_386
DWARF:
  debug_str:
    - func1
    - func2
    - func3
    - func4
    - func5
    - func6
    - func7
    - func8
    - func9
  debug_abbrev:
    - ID:              0
      Table:
        - Code:            0x1
          Tag:             DW_TAG_compile_unit
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_language
              Form:            DW_FORM_data2
        - Code:            0x2
          Tag:             DW_TAG_subprogram
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_low_pc
              Form:            DW_FORM_addr
            - Attribute:       DW_AT_high_pc
              Form:            DW_FORM_data4
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_calling_convention
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_external
              Form:            DW_FORM_flag_present
  debug_info:
    - Version:         4
      AddrSize:        4
      Entries:
        - AbbrCode:        0x1
          Values:
            - Value:           0xC
        - AbbrCode:        0x2
          Values:
            - Value:           0x0
            - Value:           0x5
            - Value:           0x00
            - Value:           0xCB
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x10
            - Value:           0x5
            - Value:           0x06
            - Value:           0xB3
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x20
            - Value:           0x5
            - Value:           0x0C
            - Value:           0xB1
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x30
            - Value:           0x5
            - Value:           0x12
            - Value:           0xC0
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x40
            - Value:           0x5
            - Value:           0x18
            - Value:           0xB2
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x50
            - Value:           0x5
            - Value:           0x1E
            - Value:           0xC1
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x60
            - Value:           0x5
            - Value:           0x24
            - Value:           0xC2
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x70
            - Value:           0x5
            - Value:           0x2a
            - Value:           0xEE
            - Value:           0x1
        - AbbrCode:        0x2
          Values:
            - Value:           0x80
            - Value:           0x5
            - Value:           0x30
            - Value:           0x01
            - Value:           0x1
        - AbbrCode:        0x0
...
)";
  YAMLModuleTester t(yamldata);

  DWARFUnit *unit = t.GetDwarfUnit();
  ASSERT_NE(unit, nullptr);
  const DWARFDebugInfoEntry *cu_entry = unit->DIE().GetDIE();
  ASSERT_EQ(cu_entry->Tag(), DW_TAG_compile_unit);
  DWARFDIE cu_die(unit, cu_entry);

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();
  DWARFASTParserClangStub ast_parser(ast_ctx);

  std::vector<std::string> found_function_types;
  // The DWARF above is just a list of functions. Parse all of them to
  // extract the function types and their calling convention values.
  for (DWARFDIE func : cu_die.children()) {
    ASSERT_EQ(func.Tag(), DW_TAG_subprogram);
    SymbolContext sc;
    bool new_type = false;
    lldb::TypeSP type = ast_parser.ParseTypeFromDWARF(sc, func, &new_type);
    found_function_types.push_back(
        type->GetForwardCompilerType().GetTypeName().AsCString());
  }

  // Compare the parsed function types against the expected list of types.
  const std::vector<std::string> expected_function_types = {
      "void () __attribute__((regcall))",
      "void () __attribute__((fastcall))",
      "void () __attribute__((stdcall))",
      "void () __attribute__((vectorcall))",
      "void () __attribute__((pascal))",
      "void () __attribute__((ms_abi))",
      "void () __attribute__((sysv_abi))",
      "void ()", // invalid calling convention.
      "void ()", // DW_CC_normal -> no attribute
  };
  ASSERT_EQ(found_function_types, expected_function_types);
}

TEST_F(DWARFASTParserClangTests, TestPtrAuthParsing) {
  // Tests parsing values with type DW_TAG_LLVM_ptrauth_type corresponding to
  // explicitly signed raw function pointers

  // This is Dwarf for the following C code:
  // ```
  // void (*__ptrauth(0, 0, 42) a)();
  // ```

  const char *yamldata = R"(
--- !ELF
FileHeader:
  Class:   ELFCLASS64
  Data:    ELFDATA2LSB
  Type:    ET_EXEC
  Machine: EM_AARCH64
DWARF:
  debug_str:
    - a
  debug_abbrev:
    - ID:              0
      Table:
        - Code:            0x01
          Tag:             DW_TAG_compile_unit
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_language
              Form:            DW_FORM_data2
        - Code:            0x02
          Tag:             DW_TAG_variable
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_external
              Form:            DW_FORM_flag_present
        - Code:            0x03
          Tag:             DW_TAG_LLVM_ptrauth_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_LLVM_ptrauth_key
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_LLVM_ptrauth_extra_discriminator
              Form:            DW_FORM_data2
        - Code:            0x04
          Tag:             DW_TAG_pointer_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
        - Code:            0x05
          Tag:             DW_TAG_subroutine_type
          Children:        DW_CHILDREN_yes
        - Code:            0x06
          Tag:             DW_TAG_unspecified_parameters
          Children:        DW_CHILDREN_no

  debug_info:
    - Version:         5
      UnitType:        DW_UT_compile
      AddrSize:        8
      Entries:
# 0x0c: DW_TAG_compile_unit
#         DW_AT_language [DW_FORM_data2]    (DW_LANG_C99)
        - AbbrCode:        0x01
          Values:
            - Value:           0x0c

# 0x0f:   DW_TAG_variable
#           DW_AT_name [DW_FORM_strp]       (\"a\")
#           DW_AT_type [DW_FORM_ref4]       (0x00000018 \"void (*__ptrauth(0, 0, 0x02a)\")
#           DW_AT_external [DW_FORM_flag_present]   (true)
        - AbbrCode:        0x02
          Values:
            - Value:           0x00
            - Value:           0x18

# 0x18:   DW_TAG_LLVM_ptrauth_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000020 \"void (*)(...)\")
#           DW_AT_LLVM_ptrauth_key [DW_FORM_data1]  (0x00)
#           DW_AT_LLVM_ptrauth_extra_discriminator [DW_FORM_data2]  (0x002a)
        - AbbrCode:        0x03
          Values:
            - Value:           0x20
            - Value:           0x00
            - Value:           0x2a

# 0x20:   DW_TAG_pointer_type
#           DW_AT_type [DW_AT_type [DW_FORM_ref4]       (0x00000025 \"void (...)\")
        - AbbrCode:        0x04
          Values:
            - Value:           0x25

# 0x25:   DW_TAG_subroutine_type
        - AbbrCode:        0x05

# 0x26:     DW_TAG_unspecified_parameters
        - AbbrCode:        0x06

        - AbbrCode:        0x00 # end of child tags of 0x25
        - AbbrCode:        0x00 # end of child tags of 0x0c
...
)";
  YAMLModuleTester t(yamldata);

  DWARFUnit *unit = t.GetDwarfUnit();
  ASSERT_NE(unit, nullptr);
  const DWARFDebugInfoEntry *cu_entry = unit->DIE().GetDIE();
  ASSERT_EQ(cu_entry->Tag(), DW_TAG_compile_unit);
  DWARFDIE cu_die(unit, cu_entry);

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();
  DWARFASTParserClangStub ast_parser(ast_ctx);

  DWARFDIE ptrauth_variable = cu_die.GetFirstChild();
  ASSERT_EQ(ptrauth_variable.Tag(), DW_TAG_variable);
  DWARFDIE ptrauth_type =
      ptrauth_variable.GetAttributeValueAsReferenceDIE(DW_AT_type);
  ASSERT_EQ(ptrauth_type.Tag(), DW_TAG_LLVM_ptrauth_type);

  SymbolContext sc;
  bool new_type = false;
  lldb::TypeSP type =
      ast_parser.ParseTypeFromDWARF(sc, ptrauth_type, &new_type);
  std::string type_as_string =
      type->GetForwardCompilerType().GetTypeName().AsCString();
  ASSERT_EQ(type_as_string, "void (*__ptrauth(0,0,42))(...)");
}

TEST_F(DWARFASTParserClangTests, TestVTablePtrAuthParsing) {
  // Tests parsing dynamic structure types with explicit vtable pointer
  // authentication

  // This is Dwarf for the following C++ code:
  // ```
  // struct [[clang::ptrauth_vtable_pointer(process_dependent,
  //                                        address_discrimination,
  //                                        custom_discrimination, 42)]] A {
  //   virtual void foo() {}
  // };
  // A a;
  // ```

  const char *yamldata = R"(
--- !ELF
FileHeader:
  Class:   ELFCLASS64
  Data:    ELFDATA2LSB
  Type:    ET_EXEC
  Machine: EM_AARCH64
DWARF:
  debug_str:
    - a
    - A
    - _vptr$A
    - foo
    - __vtbl_ptr_type
    - int
  debug_abbrev:
    - ID:              0
      Table:
        - Code:            0x1
          Tag:             DW_TAG_compile_unit
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_language
              Form:            DW_FORM_data2
        - Code:            0x2
          Tag:             DW_TAG_variable
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_external
              Form:            DW_FORM_flag_present
        - Code:            0x3
          Tag:             DW_TAG_structure_type
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_containing_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
        - Code:            0x4
          Tag:             DW_TAG_member
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_artificial
              Form:            DW_FORM_flag_present
        - Code:            0x5
          Tag:             DW_TAG_subprogram
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_virtuality
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_containing_type
              Form:            DW_FORM_ref4
        - Code:            0x6
          Tag:             DW_TAG_formal_parameter
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_artificial
              Form:            DW_FORM_flag_present
        - Code:            0x7
          Tag:             DW_TAG_LLVM_ptrauth_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_LLVM_ptrauth_key
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_LLVM_ptrauth_extra_discriminator
              Form:            DW_FORM_data2
            - Attribute:       DW_AT_LLVM_ptrauth_address_discriminated
              Form:            DW_FORM_flag_present
        - Code:            0x8
          Tag:             DW_TAG_pointer_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
        - Code:            0x9
          Tag:             DW_TAG_pointer_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
        - Code:            0xA
          Tag:             DW_TAG_subroutine_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
        - Code:            0xB
          Tag:             DW_TAG_base_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_encoding
              Form:            DW_FORM_data1
            - Attribute:       DW_AT_byte_size
              Form:            DW_FORM_data1
        - Code:            0xC
          Tag:             DW_TAG_pointer_type
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4

  debug_info:
    - Version:         5
      UnitType:        DW_UT_compile
      AddrSize:        8
      Entries:
# 0x0c: DW_TAG_compile_unit
#         DW_AT_language [DW_FORM_data2]    (DW_LANG_C_plus_plus_11)
        - AbbrCode:        0x1
          Values:
            - Value:           0x1A

# 0x0f:   DW_TAG_variable
#           DW_AT_name [DW_FORM_strp]       (\"a\")
#           DW_AT_type [DW_FORM_ref4]       (0x00000018 \"A\")
#           DW_AT_external [DW_FORM_flag_present]   (true)
        - AbbrCode:        0x2
          Values:
            - Value:           0x00
            - Value:           0x18

# 0x18:   DW_TAG_structure_type
#           DW_AT_containing_type [DW_FORM_ref4]    (0x00000018 \"A\")
#           DW_AT_name [DW_FORM_strp]       (\"A\")
        - AbbrCode:        0x3
          Values:
            - Value:           0x18
            - Value:           0x02

# 0x21:     DW_TAG_member
#             DW_AT_name [DW_FORM_strp]     (\"_vptr$A\")
#             DW_AT_type [DW_FORM_ref4]     (0x0000002f)
#             DW_AT_artificial [DW_FORM_flag_present]       (true)
        - AbbrCode:        0x4
          Values:
            - Value:           0x04
            - Value:           0x3B

# 0x2a:     DW_TAG_subprogram
#             DW_AT_name [DW_FORM_strp]     (\"foo\")
#             DW_AT_virtuality [DW_FORM_data1]      (DW_VIRTUALITY_virtual)
#             DW_AT_containing_type [DW_FORM_ref4]  (0x00000018 \"A\")
        - AbbrCode:        0x5
          Values:
            - Value:           0x0C
            - Value:           0x01
            - Value:           0x18

# 0x34:       DW_TAG_formal_parameter
#               DW_AT_type [DW_FORM_ref4]   (0x0000005d \"A *\")
#               DW_AT_artificial [DW_FORM_flag_present]     (true)
        - AbbrCode:        0x6
          Values:
            - Value:           0x5D

        - AbbrCode:        0x0 # end of child tags of 0x2a
        - AbbrCode:        0x0 # end of child tags of 0x18

# 0x3b:   DW_TAG_LLVM_ptrauth_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000043 \"int (**)()\")
#           DW_AT_LLVM_ptrauth_key [DW_FORM_data1]  (0x02)
#           DW_AT_LLVM_ptrauth_extra_discriminator [DW_FORM_data2]  (0x002a)
#           DW_AT_LLVM_ptrauth_address_discriminated [DW_FORM_flag_present] (true)
        - AbbrCode:        0x7
          Values:
            - Value:           0x43
            - Value:           0x02
            - Value:           0x2A

# 0x43:   DW_TAG_pointer_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000048 \"int (*)()\")
        - AbbrCode:        0x8
          Values:
            - Value:           0x48

# 0x48:   DW_TAG_pointer_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000051 \"int ()\")
#           DW_AT_name [DW_FORM_strp]       (\"__vtbl_ptr_type\")
        - AbbrCode:        0x9
          Values:
            - Value:           0x51
            - Value:           0x10

# 0x51:   DW_TAG_subroutine_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000056 \"int\")
        - AbbrCode:        0xA
          Values:
            - Value:           0x56

# 0x56:   DW_TAG_base_type
#           DW_AT_name [DW_FORM_strp]       (\"int\")
#           DW_AT_encoding [DW_FORM_data1]  (DW_ATE_signed)
#           DW_AT_byte_size [DW_FORM_data1] (0x04)
        - AbbrCode:        0xB
          Values:
            - Value:           0x20
            - Value:           0x05
            - Value:           0x04

# 0x5d:   DW_TAG_pointer_type
#           DW_AT_type [DW_FORM_ref4]       (0x00000018 \"A\")
        - AbbrCode:        0xC
          Values:
            - Value:           0x18

        - AbbrCode:        0x0 # end of child tags of 0x0c
...
)";
  YAMLModuleTester t(yamldata);

  DWARFUnit *unit = t.GetDwarfUnit();
  ASSERT_NE(unit, nullptr);
  const DWARFDebugInfoEntry *cu_entry = unit->DIE().GetDIE();
  ASSERT_EQ(cu_entry->Tag(), DW_TAG_compile_unit);
  DWARFDIE cu_die(unit, cu_entry);

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();
  DWARFASTParserClangStub ast_parser(ast_ctx);

  DWARFDIE struct_object = cu_die.GetFirstChild();
  ASSERT_EQ(struct_object.Tag(), DW_TAG_variable);
  DWARFDIE structure_type =
      struct_object.GetAttributeValueAsReferenceDIE(DW_AT_type);
  ASSERT_EQ(structure_type.Tag(), DW_TAG_structure_type);

  SymbolContext sc;
  bool new_type = false;
  lldb::TypeSP type =
      ast_parser.ParseTypeFromDWARF(sc, structure_type, &new_type);
  clang::RecordDecl *record_decl =
      TypeSystemClang::GetAsRecordDecl(type->GetForwardCompilerType());
  auto *attr = record_decl->getAttr<clang::VTablePointerAuthenticationAttr>();
  ASSERT_NE(attr, nullptr);
  ASSERT_EQ(attr->getKey(),
            clang::VTablePointerAuthenticationAttr::ProcessDependent);
  ASSERT_EQ(attr->getAddressDiscrimination(),
            clang::VTablePointerAuthenticationAttr::AddressDiscrimination);
  ASSERT_EQ(attr->getExtraDiscrimination(),
            clang::VTablePointerAuthenticationAttr::CustomDiscrimination);
  ASSERT_EQ(attr->getCustomDiscriminationValue(), 42);
}

TEST_F(DWARFASTParserClangTests, TestPtrAuthStructAttr) {
  // Tests parsing types with ptrauth_struct attribute
  // authentication

  // This is Dwarf for the following C code:
  // ```
  // struct [[clang::ptrauth_struct(2, 42)]] A {};
  // struct A a;
  // ```

  const char *yamldata = R"(
--- !ELF
FileHeader:
  Class:   ELFCLASS64
  Data:    ELFDATA2LSB
  Type:    ET_EXEC
  Machine: EM_AARCH64
DWARF:
  debug_str:
    - a
    - A
    - ptrauth_struct_key
    - ptrauth_struct_disc
  debug_abbrev:
    - ID:              0
      Table:
        - Code:            0x1
          Tag:             DW_TAG_compile_unit
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_language
              Form:            DW_FORM_data2
        - Code:            0x2
          Tag:             DW_TAG_variable
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_type
              Form:            DW_FORM_ref4
            - Attribute:       DW_AT_external
              Form:            DW_FORM_flag_present
        - Code:            0x3
          Tag:             DW_TAG_structure_type
          Children:        DW_CHILDREN_yes
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
        - Code:            0x4
          Tag:             DW_TAG_LLVM_annotation
          Children:        DW_CHILDREN_no
          Attributes:
            - Attribute:       DW_AT_name
              Form:            DW_FORM_strp
            - Attribute:       DW_AT_const_value
              Form:            DW_FORM_udata

  debug_info:
    - Version:         5
      UnitType:        DW_UT_compile
      AddrSize:        8
      Entries:
# 0x0c: DW_TAG_compile_unit
#         DW_AT_language [DW_FORM_data2]    (DW_LANG_C99)
        - AbbrCode:        0x1
          Values:
            - Value:           0x0c

# 0x0f:   DW_TAG_variable
#           DW_AT_name [DW_FORM_strp]       (\"a\")
#           DW_AT_type [DW_FORM_ref4]       (0x00000018 \"A\")
#           DW_AT_external [DW_FORM_flag_present]   (true)
        - AbbrCode:        0x2
          Values:
            - Value:           0x00
            - Value:           0x18

# 0x18:   DW_TAG_structure_type
#           DW_AT_name [DW_FORM_strp]       (\"A\")
        - AbbrCode:        0x3
          Values:
            - Value:           0x02

# 0x1d:     DW_TAG_LLVM_annotation
#             DW_AT_name [DW_FORM_strp]     (\"ptrauth_struct_key\")
#             DW_AT_const_value [DW_FORM_udata]  (2)
        - AbbrCode:        0x4
          Values:
            - Value:           0x04
            - Value:           0x02

# 0x23:     DW_TAG_LLVM_annotation
#             DW_AT_name [DW_FORM_strp]     (\"ptrauth_struct_disc\")
#             DW_AT_const_value [DW_FORM_udata]  (42)
        - AbbrCode:        0x4
          Values:
            - Value:           0x17
            - Value:           0x2a

        - AbbrCode:        0x0 # end of child tags of 0x18
        - AbbrCode:        0x0 # end of child tags of 0x0c
...
)";
  YAMLModuleTester t(yamldata);

  DWARFUnit *unit = t.GetDwarfUnit();
  ASSERT_NE(unit, nullptr);
  const DWARFDebugInfoEntry *cu_entry = unit->DIE().GetDIE();
  ASSERT_EQ(cu_entry->Tag(), DW_TAG_compile_unit);
  DWARFDIE cu_die(unit, cu_entry);

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();
  DWARFASTParserClangStub ast_parser(ast_ctx);

  DWARFDIE struct_object = cu_die.GetFirstChild();
  ASSERT_EQ(struct_object.Tag(), DW_TAG_variable);
  DWARFDIE structure_type =
      struct_object.GetAttributeValueAsReferenceDIE(DW_AT_type);
  ASSERT_EQ(structure_type.Tag(), DW_TAG_structure_type);

  SymbolContext sc;
  bool new_type = false;
  lldb::TypeSP type =
      ast_parser.ParseTypeFromDWARF(sc, structure_type, &new_type);
  clang::RecordDecl *record_decl =
      TypeSystemClang::GetAsRecordDecl(type->GetForwardCompilerType());
  auto [is_key_val_independent, key] =
      ast_ctx.getASTContext().getPointerAuthStructKey(record_decl);
  auto [is_disc_val_independent, disc] =
      ast_ctx.getASTContext().getPointerAuthStructDisc(record_decl);
  ASSERT_TRUE(is_key_val_independent);
  ASSERT_TRUE(is_disc_val_independent);
  ASSERT_EQ(key, 2);
  ASSERT_EQ(disc, 42);
}

struct ExtractIntFromFormValueTest : public testing::Test {
  SubsystemRAII<FileSystem, HostInfo> subsystems;
  clang_utils::TypeSystemClangHolder holder;
  TypeSystemClang &ts;

  DWARFASTParserClang parser;
  ExtractIntFromFormValueTest()
      : holder("dummy ASTContext"), ts(*holder.GetAST()), parser(ts) {}

  /// Takes the given integer value, stores it in a DWARFFormValue and then
  /// tries to extract the value back via
  /// DWARFASTParserClang::ExtractIntFromFormValue.
  /// Returns the string representation of the extracted value or the error
  /// that was returned from ExtractIntFromFormValue.
  llvm::Expected<std::string> Extract(clang::QualType qt, uint64_t value) {
    DWARFFormValue form_value;
    form_value.SetUnsigned(value);
    llvm::Expected<llvm::APInt> result =
        parser.ExtractIntFromFormValue(ts.GetType(qt), form_value);
    if (!result)
      return result.takeError();
    llvm::SmallString<16> result_str;
    result->toStringUnsigned(result_str);
    return std::string(result_str.str());
  }

  /// Same as ExtractIntFromFormValueTest::Extract but takes a signed integer
  /// and treats the result as a signed integer.
  llvm::Expected<std::string> ExtractS(clang::QualType qt, int64_t value) {
    DWARFFormValue form_value;
    form_value.SetSigned(value);
    llvm::Expected<llvm::APInt> result =
        parser.ExtractIntFromFormValue(ts.GetType(qt), form_value);
    if (!result)
      return result.takeError();
    llvm::SmallString<16> result_str;
    result->toStringSigned(result_str);
    return std::string(result_str.str());
  }
};

TEST_F(ExtractIntFromFormValueTest, TestBool) {
  using namespace llvm;
  clang::ASTContext &ast = ts.getASTContext();

  EXPECT_THAT_EXPECTED(Extract(ast.BoolTy, 0), HasValue("0"));
  EXPECT_THAT_EXPECTED(Extract(ast.BoolTy, 1), HasValue("1"));
  EXPECT_THAT_EXPECTED(Extract(ast.BoolTy, 2), Failed());
  EXPECT_THAT_EXPECTED(Extract(ast.BoolTy, 3), Failed());
}

TEST_F(ExtractIntFromFormValueTest, TestInt) {
  using namespace llvm;

  clang::ASTContext &ast = ts.getASTContext();

  // Find the min/max values for 'int' on the current host target.
  constexpr int64_t int_max = std::numeric_limits<int>::max();
  constexpr int64_t int_min = std::numeric_limits<int>::min();

  // Check that the bit width of int matches the int width in our type system.
  ASSERT_EQ(sizeof(int) * 8, ast.getIntWidth(ast.IntTy));

  // Check values around int_min.
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min - 2), llvm::Failed());
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min - 1), llvm::Failed());
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min),
                       HasValue(std::to_string(int_min)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min + 1),
                       HasValue(std::to_string(int_min + 1)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min + 2),
                       HasValue(std::to_string(int_min + 2)));

  // Check values around 0.
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, -128), HasValue("-128"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, -10), HasValue("-10"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, -1), HasValue("-1"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, 0), HasValue("0"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, 1), HasValue("1"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, 10), HasValue("10"));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, 128), HasValue("128"));

  // Check values around int_max.
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max - 2),
                       HasValue(std::to_string(int_max - 2)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max - 1),
                       HasValue(std::to_string(int_max - 1)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max),
                       HasValue(std::to_string(int_max)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max + 1), llvm::Failed());
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max + 5), llvm::Failed());

  // Check some values not near an edge case.
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_max / 2),
                       HasValue(std::to_string(int_max / 2)));
  EXPECT_THAT_EXPECTED(ExtractS(ast.IntTy, int_min / 2),
                       HasValue(std::to_string(int_min / 2)));
}

TEST_F(ExtractIntFromFormValueTest, TestUnsignedInt) {
  using namespace llvm;

  clang::ASTContext &ast = ts.getASTContext();
  constexpr uint64_t uint_max = std::numeric_limits<uint32_t>::max();

  // Check values around 0.
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, 0), HasValue("0"));
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, 1), HasValue("1"));
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, 1234), HasValue("1234"));

  // Check some values not near an edge case.
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max / 2),
                       HasValue(std::to_string(uint_max / 2)));

  // Check values around uint_max.
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max - 2),
                       HasValue(std::to_string(uint_max - 2)));
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max - 1),
                       HasValue(std::to_string(uint_max - 1)));
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max),
                       HasValue(std::to_string(uint_max)));
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max + 1),
                       llvm::Failed());
  EXPECT_THAT_EXPECTED(Extract(ast.UnsignedIntTy, uint_max + 2),
                       llvm::Failed());
}

TEST_F(DWARFASTParserClangTests, TestDefaultTemplateParamParsing) {
  // Tests parsing DW_AT_default_value for template parameters.
  auto BufferOrError = llvm::MemoryBuffer::getFile(
      GetInputFilePath("DW_AT_default_value-test.yaml"), /*IsText=*/true);
  ASSERT_TRUE(BufferOrError);
  YAMLModuleTester t(BufferOrError.get()->getBuffer());

  DWARFUnit *unit = t.GetDwarfUnit();
  ASSERT_NE(unit, nullptr);
  const DWARFDebugInfoEntry *cu_entry = unit->DIE().GetDIE();
  ASSERT_EQ(cu_entry->Tag(), DW_TAG_compile_unit);
  DWARFDIE cu_die(unit, cu_entry);

  auto holder = std::make_unique<clang_utils::TypeSystemClangHolder>("ast");
  auto &ast_ctx = *holder->GetAST();
  DWARFASTParserClangStub ast_parser(ast_ctx);

  llvm::SmallVector<lldb::TypeSP, 2> types;
  for (DWARFDIE die : cu_die.children()) {
    if (die.Tag() == DW_TAG_class_type) {
      SymbolContext sc;
      bool new_type = false;
      types.push_back(ast_parser.ParseTypeFromDWARF(sc, die, &new_type));
    }
  }

  ASSERT_EQ(types.size(), 3U);

  auto check_decl = [](auto const *decl) {
    clang::ClassTemplateSpecializationDecl const *ctsd =
        llvm::dyn_cast_or_null<clang::ClassTemplateSpecializationDecl>(decl);
    ASSERT_NE(ctsd, nullptr);

    auto const &args = ctsd->getTemplateArgs();
    ASSERT_GT(args.size(), 0U);

    for (auto const &arg : args.asArray()) {
      EXPECT_TRUE(arg.getIsDefaulted());
    }
  };

  for (auto const &type_sp : types) {
    ASSERT_NE(type_sp, nullptr);
    auto const *decl = ClangUtil::GetAsTagDecl(type_sp->GetFullCompilerType());
    if (decl->getName() == "bar" || decl->getName() == "baz") {
      check_decl(decl);
    }
  }
}
