
module("luci.controller.oneapi", package.seeall)

function index()
  entry({"admin", "services", "oneapi"}, alias("admin", "services", "oneapi", "config"), _("oneapi"), 30).dependent = true
  entry({"admin", "services", "oneapi", "config"}, cbi("oneapi"))
end
