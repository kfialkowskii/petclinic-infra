###############################################################################
# monitoring.tf — dashboard Azure Monitor z metrykami VM
#
# Metryki są zbierane automatycznie przez Azure — tu tylko wizualizacja.
###############################################################################

data "azurerm_subscription" "current" {}

resource "azurerm_portal_dashboard" "main" {
  name                = "dash-${var.project}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    title = "CPU %"
                    metrics = [{
                      resourceMetadata = { id = azurerm_linux_virtual_machine.app.id }
                      name             = "Percentage CPU"
                      aggregationType  = 4
                      namespace        = "microsoft.compute/virtualmachines"
                    }]
                  }
                }
              }]
            }
          }
          "1" = {
            position = { x = 6, y = 0, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    title = "Dostępna pamięć RAM (bytes)"
                    metrics = [{
                      resourceMetadata = { id = azurerm_linux_virtual_machine.app.id }
                      name             = "Available Memory Bytes"
                      aggregationType  = 4
                      namespace        = "microsoft.compute/virtualmachines"
                    }]
                  }
                }
              }]
            }
          }
          "2" = {
            position = { x = 0, y = 4, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    title = "Bajty sieciowe przychodzące"
                    metrics = [{
                      resourceMetadata = { id = azurerm_linux_virtual_machine.app.id }
                      name             = "Network In Total"
                      aggregationType  = 1
                      namespace        = "microsoft.compute/virtualmachines"
                    }]
                  }
                }
              }]
            }
          }
          "3" = {
            position = { x = 6, y = 4, rowSpan = 4, colSpan = 6 }
            metadata = {
              type = "Extension/HubsExtension/PartType/MonitorChartPart"
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    title = "Operacje dyskowe/s"
                    metrics = [{
                      resourceMetadata = { id = azurerm_linux_virtual_machine.app.id }
                      name             = "Disk Read Operations/Sec"
                      aggregationType  = 4
                      namespace        = "microsoft.compute/virtualmachines"
                    }]
                  }
                }
              }]
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = { relative = { duration = 24, timeUnit = 1 } }
          type  = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}