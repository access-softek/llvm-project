#!/usr/bin/env python3

import argparse
import os
import io
import tempfile
import re
import subprocess
import shutil

import di_stat

re_run_line = re.compile(r"^\s*;\s*RUN:.*$")
re_check_line = re.compile(r"^\s*;\s*CHECK(-.+)?:.*$")


def filterLine(orig):
    line = re_run_line.sub("", orig)
    line = re_check_line.sub("", line)

    # Drop lines that we filtered out, but keep original emtpy lines.
    if (not line.strip()) and line != orig:
        return None
    return line


run_line = """
; RUN: llc -mtriple=dxil-pc-shadermodel6.3-library --filetype=obj -o %t.dxbc %s
; RUN: llvm-objcopy --dump-section=ILDB=%t.bc %t.dxbc
; RUN: llvm-dis-3.7 -o %t.bc | %python %S/di_stat.py > %t.stat
; RUN: FileCheck %s --input-file %t.stat
""".lstrip()


def formatStatChecks(stat):
    sorted_stats = sorted(stat.items(), key=lambda kv: kv[0])
    checks = (f"; CHECK: {di}: {count}" for di, count in sorted_stats)
    return "\n".join(checks)


def processLines(outs, lines, stat):
    outs.write(run_line)
    outs.write("\n")
    outs.write(formatStatChecks(stat))

    for line in lines:
        line = filterLine(line)
        if line:
            outs.write(line)


def upgradeIr(input_file, llvm_as, llvm_dis):
    proc_as = subprocess.Popen([llvm_as], stdin=input_file, stdout=subprocess.PIPE)
    proc_dis = subprocess.Popen(
        [llvm_dis], stdin=proc_as.stdout, stdout=subprocess.PIPE, text=True
    )
    out, err = proc_dis.communicate()

    if proc_as.wait() or proc_dis.wait():
        raise RuntimeError("LLVM error")
    return out


def main(args):
    with open(args.input) as f:
        stat = di_stat.processLines(
            upgradeIr(f, args.llvm_as, args.llvm_dis).split("\n")
        )

    with open(args.input) as f:
        input_lines = f.readlines()

    with open(args.output, "w") as outs:
        processLines(outs, input_lines, stat)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="di_update.py",
        description="Replace existing CHECK and RUN line with di_stat checks.",
    )
    parser.add_argument("input", help=".ll file to process")
    parser.add_argument("-o", dest="output", default="-", help="output file")
    parser.add_argument(
        "--llvm-as", default=shutil.which("llvm-as"), help="path to llvm-as"
    )
    parser.add_argument(
        "--llvm-dis", default=shutil.which("llvm-dis"), help="path to llvm-dis"
    )
    args = parser.parse_args()
    main(args)
