/**
 * Session naming — /session-name [name]
 *
 * Set or show the session name. Named sessions appear in the session selector
 * instead of the first message, making it easier to navigate between sessions.
 *
 * Usage:
 *   /session-name          — show current session name
 *   /session-name my-task  — set session name to "my-task"
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("session-name", {
    description: "Set or show session name (usage: /session-name [new name])",
    handler: async (args, ctx) => {
      const name = args.trim();

      if (name) {
        pi.setSessionName(name);
        ctx.ui.notify(`Session named: ${name}`, "info");
      } else {
        const current = pi.getSessionName();
        ctx.ui.notify(
          current ? `Session: ${current}` : "No session name set",
          "info",
        );
      }
    },
  });
}
