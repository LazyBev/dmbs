import std.stdio;
import std.process;
import std.string;
import std.file;
import core.stdc.stdlib;
import std.datetime;

void usage() {
}

bool cmd(scope const(char[])[] args) {
    writeln("CMD: ", args);
    return wait(spawnProcess(args)) == 0;
}

bool needsRebuild(string outputPath, string inputPath) {
    SysTime ignore;
    SysTime inModifiedTime;
    SysTime outModifiedTime;
    getTimes(outputPath, ignore, outModifiedTime);
    getTimes(inputPath, ignore, inModifiedTime);
    return inModifiedTime > outModifiedTime;
}

void goRebuild(string[] args, string sourcePath = __FILE__,) {
    string binaryPath = args[0];
    if (!needsRebuild(binaryPath, sourcePath)) return;
    string oldBinaryPath = format("%s.old", binaryPath);
    writeln("RENAME: ", binaryPath, " -> ", oldBinaryPath);
    rename(binaryPath, oldBinaryPath);
    if (!cmd(["dmd", format("-of=%s", binaryPath), sourcePath])) {
        writeln("RENAME: ", oldBinaryPath, " -> ", binaryPath);
        rename(oldBinaryPath, binaryPath);
        exit(1);
    }
    writeln("REMOVE: ", oldBinaryPath);
    remove(oldBinaryPath);
    if (!cmd([format("./%s",binaryPath)])) exit(1);
    exit(0);
}

int main(string[] args) {
    goRebuild(args);
    if (!cmd(["dmd", "-O", "toa.d", "./raylib-5.5_linux_amd64/include/raylib.c", format("-L=%s", "-l:libraylib.so.550"), "-L=-L=./raylib-5.5_linux_amd64/lib/"])) return 1;
    return 0;
}