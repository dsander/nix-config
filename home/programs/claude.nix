{ config, lib, ... }:
# Second Claude Code account (`claudep`) living in ~/.claude-p, next to the
# personal one in ~/.claude.
#
# CLAUDE_CONFIG_DIR keeps login, ~/.claude.json, settings and caches separate,
# while the entries below are symlinked to ~/.claude so both accounts share
# chat history (`--resume` works across accounts), auto-memory and the
# user-level instructions/skills.
let
  home = config.home.homeDirectory;
  personalDir = "${home}/.claude";
  profileDir = ".claude-p";

  sharedDirs = [
    "projects" # session transcripts + per-project auto-memory
    "file-history" # checkpoints, needed to /rewind resumed sessions
    "plans" # plan-mode files referenced by sessions
    "todos" # per-session todo lists
    "skills"
    "agents"
    "commands"
  ];
  sharedFiles = [
    "CLAUDE.md"
  ];
in
{
  home.shellAliases.claudep = "CLAUDE_CONFIG_DIR=$HOME/${profileDir} claude";

  home.file = lib.listToAttrs (map
    (name: lib.nameValuePair "${profileDir}/${name}" {
      source = config.lib.file.mkOutOfStoreSymlink "${personalDir}/${name}";
    })
    (sharedDirs ++ sharedFiles));

  # ~/.claude does not exist on fresh installs; create the link targets so the
  # symlinks above are never dangling directories.
  home.activation.createClaudeSharedDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.concatMapStringsSep " " (d: lib.escapeShellArg "${personalDir}/${d}") sharedDirs}
  '';
}
