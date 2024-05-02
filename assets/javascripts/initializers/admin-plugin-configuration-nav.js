import { PLUGIN_NAV_MODE_TOP } from "discourse/lib/admin-plugin-config-nav";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-gamification-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi("1.1.0", (api) => {
      api.addAdminPluginConfigurationNav(
        "discourse-gamification",
        PLUGIN_NAV_MODE_TOP,
        [
          {
            label: "gamification.leaderboard.title",
            route: "adminPlugins.show.discourse-gamification-leaderboards",
          },
        ]
      );
    });
  },
};
