{
  "apiVersion": "dashboard.grafana.app/v2",
  "kind": "Dashboard",
  "metadata": {
    "name": "000000001",
    "namespace": "default",
    "uid": "LDII5cTpNTaXKYqbZkKOLay5RGaJerTQhrjQjWJDfKQX",
    "resourceVersion": "1755528670000018",
    "generation": 6,
    "creationTimestamp": "2025-05-19T12:44:17Z",
    "labels": {
      "grafana.app/deprecatedInternalID": "1"
    },
    "annotations": {
      "grafana.app/createdBy": "user:aemcnmocwv94wb",
      "grafana.app/updatedBy": "user:aemcnmocwv94wb",
      "grafana.app/updatedTimestamp": "2025-08-18T14:51:19Z"
    }
  },
  "spec": {
    "annotations": [
      {
        "kind": "AnnotationQuery",
        "spec": {
          "query": {
            "kind": "DataQuery",
            "group": "datasource",
            "version": "v0",
            "datasource": {
              "name": "grafana"
            },
            "spec": {}
          },
          "enable": true,
          "hide": true,
          "iconColor": "rgba(0, 211, 255, 1)",
          "name": "Annotations & Alerts",
          "builtIn": true,
          "legacyOptions": {
            "type": "dashboard"
          }
        }
      },
      {
        "kind": "AnnotationQuery",
        "spec": {
          "query": {
            "kind": "DataQuery",
            "group": "prometheus",
            "version": "v0",
            "datasource": {
              "name": "PBFA97CFB590B2093"
            },
            "spec": {}
          },
          "enable": false,
          "hide": false,
          "iconColor": "rgb(252, 5, 0)",
          "name": "Alert",
          "legacyOptions": {
            "expr": "ALERTS{alias=\"$host\", alertstate=\"firing\"}",
            "tagKeys": "severity",
            "textFormat": "{{ alias }} : {{alertstate}}",
            "titleFormat": "{{ alertname }}"
          }
        }
      },
      {
        "kind": "AnnotationQuery",
        "spec": {
          "query": {
            "kind": "DataQuery",
            "group": "prometheus",
            "version": "v0",
            "datasource": {
              "name": "PBFA97CFB590B2093"
            },
            "spec": {}
          },
          "enable": false,
          "hide": false,
          "iconColor": "rgb(228, 242, 9)",
          "name": "Warning",
          "legacyOptions": {
            "expr": "ALERTS{alias=\"$host\",alertstate=\"pending\"}",
            "tagKeys": "severity",
            "textFormat": "{{ alias }} : {{ alertstate }}",
            "titleFormat": "{{ alertname }}"
          }
        }
      }
    ],
    "cursorSync": "Crosshair",
    "description": "Prometheus for system metrics. \r\nLoad, CPU, RAM, network, process ... ",
    "editable": true,
    "elements": {
      "panel-18": {
        "kind": "Panel",
        "spec": {
          "id": 18,
          "title": "Load Average",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "10s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_load1{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Load 1m",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_load1%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%223601s%22%2C%22end_input%22%3A%222015-10-22%2015%3A27%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Afalse%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 2,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "10s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_load5{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Load 5m",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_load5%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%223600s%22%2C%22end_input%22%3A%222015-10-22%2015%3A27%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Afalse%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 2,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "10s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_load15{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Load 15m",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_load15%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%223600s%22%2C%22end_input%22%3A%222015-10-22%2015%3A27%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Afalse%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 2,
                        "target": ""
                      }
                    },
                    "refId": "C",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "right",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Load 1m"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#E24D42",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Load 5m"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#E0752D",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Load 15m"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#E5AC0E",
                          "mode": "fixed"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-19": {
        "kind": "Panel",
        "spec": {
          "id": 19,
          "title": "System Uptime",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "10m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_time_seconds{job=\"$host\"} - node_boot_time_seconds{job=\"$host\"}",
                        "format": "time_series",
                        "interval": "5m",
                        "intervalFactor": 1,
                        "legendFormat": "",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_time%7Balias%3D%5C%22%24host%5C%22%7D%20-%20node_boot_time%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A25%22%2C%22step_input%22%3A%22%22%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 300
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {
                "maxDataPoints": 100
              }
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "stat",
            "version": "12.1.1",
            "spec": {
              "options": {
                "colorMode": "value",
                "graphMode": "none",
                "justifyMode": "auto",
                "orientation": "horizontal",
                "percentChangeColorMode": "standard",
                "reduceOptions": {
                  "calcs": [
                    "lastNotNull"
                  ],
                  "fields": "",
                  "values": false
                },
                "showPercentChange": false,
                "textMode": "auto",
                "wideLayout": true
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "s",
                  "decimals": 1,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "rgba(245, 54, 54, 0.9)"
                      },
                      {
                        "value": 300,
                        "color": "rgba(237, 129, 40, 0.89)"
                      },
                      {
                        "value": 3600,
                        "color": "rgba(50, 172, 45, 0.97)"
                      }
                    ]
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-2": {
        "kind": "Panel",
        "spec": {
          "id": 2,
          "title": "CPU Usage",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "sum(rate(node_cpu_seconds_total{job=\"$host\"}[$interval])) by (mode) * 100 / count(node_cpu_seconds_total{job=\"$host\"}) by (mode) or sum(irate(node_cpu_seconds_total{job=\"$host\"}[5m])) by (mode) * 100 / count(node_cpu_seconds_total{job=\"$host\"}) by (mode)",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "{{ mode }}",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22sum(rate(node_cpu%7Balias%3D%5C%22%24host%5C%22%7D%5B%24interval%5D))%20by%20(mode)%20*%20100%22%2C%22range_input%22%3A%223600s%22%2C%22end_input%22%3A%222015-10-22%2015%3A27%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 2
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "right",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "percent",
                  "min": 0,
                  "max": 100,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 60,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-20": {
        "kind": "Panel",
        "spec": {
          "id": 20,
          "title": "Processes",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_procs_running{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Processes in runnable state",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_procs_running%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A46%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_procs_blocked{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Processes blocked waiting for I/O to complete",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_procs_blocked%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A46%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "bars",
                    "fillOpacity": 100,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Processes blocked waiting for I/O to complete"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#E24D42",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Processes in runnable state"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#6ED0E0",
                          "mode": "fixed"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-21": {
        "kind": "Panel",
        "spec": {
          "id": 21,
          "title": "Network Traffic",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_network_receive_bytes_total{job=\"$host\", device!=\"lo\"}[$interval]) or irate(node_network_receive_bytes_total{job=\"$host\", device!=\"lo\"}[5m])",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Inbound: {{ device }}",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_network_transmit_bytes_total{job=\"$host\", device!=\"lo\"}[$interval]) or irate(node_network_transmit_bytes_total{job=\"$host\", device!=\"lo\"}[5m])",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Outbound: {{ device }}",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "Bps",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 60,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-22": {
        "kind": "Panel",
        "spec": {
          "id": 22,
          "title": "Network Utilization Hourly",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "sum(increase(node_network_receive_bytes{job=\"$host\", device!=\"lo\"}[1h]))",
                        "format": "time_series",
                        "interval": "1h",
                        "intervalFactor": 1,
                        "legendFormat": "Received",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 3600,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "sum(increase(node_network_transmit_bytes{job=\"$host\", device!=\"lo\"}[1h]))",
                        "format": "time_series",
                        "interval": "1h",
                        "intervalFactor": 1,
                        "legendFormat": "Sent",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 3600,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {
                "timeFrom": "24h"
              }
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "bytes",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "bars",
                    "fillOpacity": 100,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-23": {
        "kind": "Panel",
        "spec": {
          "id": 23,
          "title": "Swap",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_SwapTotal_bytes{job=\"$host\"} - node_memory_SwapFree_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Used",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_SwapFree_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Free",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "bytes",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 60,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Used"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#584477",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Free"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#AEA2E0",
                          "mode": "fixed"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-24": {
        "kind": "Panel",
        "spec": {
          "id": 24,
          "title": "Forks",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_forks_total{job=\"$host\"}[$interval]) or irate(node_forks_total{job=\"$host\"}[5m])",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Forks",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_procs_running%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A46%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "bars",
                    "fillOpacity": 100,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Forks"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#EF843C",
                          "mode": "fixed"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-25": {
        "kind": "Panel",
        "spec": {
          "id": 25,
          "title": "Virtual CPUs",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "editorMode": "code",
                        "expr": "count(count(node_cpu_seconds_total{job=\"$host\"}) by (cpu))",
                        "format": "time_series",
                        "interval": "5m",
                        "intervalFactor": 1,
                        "range": true,
                        "step": 300
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {
                "maxDataPoints": 100
              }
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "stat",
            "version": "12.1.1",
            "spec": {
              "options": {
                "colorMode": "none",
                "graphMode": "none",
                "justifyMode": "auto",
                "orientation": "horizontal",
                "percentChangeColorMode": "standard",
                "reduceOptions": {
                  "calcs": [
                    "lastNotNull"
                  ],
                  "fields": "",
                  "values": false
                },
                "showPercentChange": false,
                "textMode": "auto",
                "wideLayout": true
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "mappings": [
                    {
                      "type": "special",
                      "options": {
                        "match": "null",
                        "result": {
                          "text": "N/A"
                        }
                      }
                    }
                  ],
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-26": {
        "kind": "Panel",
        "spec": {
          "id": 26,
          "title": "RAM available",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "editorMode": "code",
                        "expr": "node_memory_MemAvailable_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "interval": "",
                        "intervalFactor": 1,
                        "legendFormat": "",
                        "metric": "node_memory_MemAvailable",
                        "range": true,
                        "step": 30
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {
                "maxDataPoints": 100
              }
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "stat",
            "version": "12.1.1",
            "spec": {
              "options": {
                "colorMode": "none",
                "graphMode": "none",
                "justifyMode": "auto",
                "orientation": "horizontal",
                "percentChangeColorMode": "standard",
                "reduceOptions": {
                  "calcs": [
                    "lastNotNull"
                  ],
                  "fields": "",
                  "values": false
                },
                "showPercentChange": false,
                "textMode": "auto",
                "wideLayout": true
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "bytes",
                  "decimals": 2,
                  "mappings": [
                    {
                      "type": "special",
                      "options": {
                        "match": "null",
                        "result": {
                          "text": "N/A"
                        }
                      }
                    }
                  ],
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-27": {
        "kind": "Panel",
        "spec": {
          "id": 27,
          "title": "Context Switches",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_context_switches_total{job=\"$host\"}[$interval]) or irate(node_context_switches_total{job=\"$host\"}[5m])",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Context Switches",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_procs_running%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A46%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-28": {
        "kind": "Panel",
        "spec": {
          "id": 28,
          "title": "Interrupts",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_intr_total{job=\"$host\"}[$interval]) or irate(node_intr_total{job=\"$host\"}[5m])",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Interrupts",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_procs_running%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%2243200s%22%2C%22end_input%22%3A%222015-9-18%2013%3A46%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "none",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Interrupts"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#D683CE",
                          "mode": "fixed"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-29": {
        "kind": "Panel",
        "spec": {
          "id": 29,
          "title": "Memory Distribution",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_MemTotal_bytes{job=\"$host\"} - (node_memory_MemFree_bytes{job=\"$host\"} + node_memory_Buffers_bytes{job=\"$host\"} + node_memory_Cached_bytes{job=\"$host\"})",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Used",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_MemFree_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Free",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_Buffers_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Buffers",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "D",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_Cached_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Cached",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "E",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "bytes",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 60,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-30": {
        "kind": "Panel",
        "spec": {
          "id": 30,
          "title": "Swap Activity",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_vmstat_pswpin{job=\"$host\"}[$interval]) * 4096 or irate(node_vmstat_pswpin{job=\"$host\"}[5m]) * 4096",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Swap In",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "errors": {},
                        "expr": "rate(node_vmstat_pswpout{$tag=\"$host\"}[$interval]) * 4096 or irate(node_vmstat_pswpout{$tag=\"$host\"}[5m]) * 4096",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Swap Out",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "Bps",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-31": {
        "kind": "Panel",
        "spec": {
          "id": 31,
          "title": "I/O Activity",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "rate(node_vmstat_pgpgin{job=\"$host\"}[$interval]) * 1024 or irate(node_vmstat_pgpgin{job=\"$host\"}[5m]) * 1024",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Page In",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "errors": {},
                        "expr": "rate(node_vmstat_pgpgout{$tag=\"$host\"}[$interval]) * 1024 or irate(node_vmstat_pgpgout{$tag=\"$host\"}[5m]) * 1024",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Page Out",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "Bps",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-32": {
        "kind": "Panel",
        "spec": {
          "id": 32,
          "title": "Disk Writes",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "disableTextWrap": false,
                        "editorMode": "code",
                        "expr": "rate(node_disk_writes_completed_total{job=\"$host\"}[$interval])",
                        "fullMetaSearch": false,
                        "includeNullMetadata": false,
                        "instant": false,
                        "legendFormat": "__auto",
                        "range": true,
                        "useBackend": false
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "Bps",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 20,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "none"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": []
              }
            }
          }
        }
      },
      "panel-6": {
        "kind": "Panel",
        "spec": {
          "id": 6,
          "title": "Memory",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_MemTotal_bytes{job=\"$host\"}",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Total",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "C",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_MemTotal_bytes{alias=\"$host\"} - (node_memory_MemAvailable_bytes{job=\"$host\"} or (node_memory_MemFree_bytes{job=\"$host\"} + node_memory_Buffers_bytes{job=\"$host\"} + node_memory_Cached_bytes{job=\"$host\"}))",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Used",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20-%20(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                },
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "2s",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "node_memory_MemAvailable_bytes{job=\"$host\"} or (node_memory_MemFree_bytes{job=\"$host\"} + node_memory_Buffers_bytes{job=\"$host\"} + node_memory_Cached_bytes{job=\"$host\"})",
                        "format": "time_series",
                        "intervalFactor": 1,
                        "legendFormat": "Available",
                        "metric": "",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D%22%2C%22range_input%22%3A%22900s%22%2C%22end_input%22%3A%222015-10-22%2015%3A25%22%2C%22step_input%22%3A%22%22%2C%22stacked%22%3Atrue%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 5,
                        "target": ""
                      }
                    },
                    "refId": "B",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {}
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "timeseries",
            "version": "12.1.1",
            "spec": {
              "options": {
                "legend": {
                  "calcs": [
                    "mean",
                    "max",
                    "min"
                  ],
                  "displayMode": "table",
                  "placement": "bottom",
                  "showLegend": true
                },
                "tooltip": {
                  "hideZeros": false,
                  "mode": "multi",
                  "sort": "none"
                }
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "bytes",
                  "min": 0,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "green"
                      },
                      {
                        "value": 80,
                        "color": "red"
                      }
                    ]
                  },
                  "color": {
                    "mode": "palette-classic"
                  },
                  "custom": {
                    "axisBorderShow": false,
                    "axisCenteredZero": false,
                    "axisColorMode": "text",
                    "axisLabel": "",
                    "axisPlacement": "auto",
                    "barAlignment": 0,
                    "barWidthFactor": 0.6,
                    "drawStyle": "line",
                    "fillOpacity": 60,
                    "gradientMode": "none",
                    "hideFrom": {
                      "legend": false,
                      "tooltip": false,
                      "viz": false
                    },
                    "insertNulls": false,
                    "lineInterpolation": "linear",
                    "lineWidth": 2,
                    "pointSize": 5,
                    "scaleDistribution": {
                      "type": "linear"
                    },
                    "showPoints": "never",
                    "spanNulls": false,
                    "stacking": {
                      "group": "A",
                      "mode": "normal"
                    },
                    "thresholdsStyle": {
                      "mode": "off"
                    }
                  }
                },
                "overrides": [
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Used"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#0A437C",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Available"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#5195CE",
                          "mode": "fixed"
                        }
                      }
                    ]
                  },
                  {
                    "matcher": {
                      "id": "byName",
                      "options": "Total"
                    },
                    "properties": [
                      {
                        "id": "color",
                        "value": {
                          "fixedColor": "#052B51",
                          "mode": "fixed"
                        }
                      },
                      {
                        "id": "custom.stacking",
                        "value": {
                          "group": "A",
                          "mode": "none"
                        }
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      },
      "panel-9": {
        "kind": "Panel",
        "spec": {
          "id": 9,
          "title": "Memory Available",
          "links": [],
          "data": {
            "kind": "QueryGroup",
            "spec": {
              "queries": [
                {
                  "kind": "PanelQuery",
                  "spec": {
                    "query": {
                      "kind": "DataQuery",
                      "group": "prometheus",
                      "version": "v0",
                      "datasource": {
                        "name": "PBFA97CFB590B2093"
                      },
                      "spec": {
                        "calculatedInterval": "10m",
                        "datasourceErrors": {},
                        "editorMode": "code",
                        "errors": {},
                        "expr": "(node_memory_MemAvailable_bytes{job=\"$host\"} or (node_memory_MemFree_bytes{job=\"$host\"} + node_memory_Buffers_bytes{job=\"$host\"} + node_memory_Cached_bytes{job=\"$host\"})) / node_memory_MemTotal_bytes{job=\"$host\"} * 100",
                        "format": "time_series",
                        "interval": "5m",
                        "intervalFactor": 1,
                        "legendFormat": "",
                        "metric": "node_mem",
                        "prometheusLink": "/api/datasources/proxy/1/graph#%5B%7B%22expr%22%3A%22(node_memory_MemFree%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Buffers%7Balias%3D%5C%22%24host%5C%22%7D%20%2B%20node_memory_Cached%7Balias%3D%5C%22%24host%5C%22%7D)%20%2F%20node_memory_MemTotal%7Balias%3D%5C%22%24host%5C%22%7D%20*%20100%22%2C%22range_input%22%3A%2243201s%22%2C%22end_input%22%3A%222015-9-15%2013%3A54%22%2C%22step_input%22%3A%22%22%2C%22tab%22%3A0%7D%5D",
                        "range": true,
                        "step": 300
                      }
                    },
                    "refId": "A",
                    "hidden": false
                  }
                }
              ],
              "transformations": [],
              "queryOptions": {
                "maxDataPoints": 100
              }
            }
          },
          "vizConfig": {
            "kind": "VizConfig",
            "group": "stat",
            "version": "12.1.1",
            "spec": {
              "options": {
                "colorMode": "value",
                "graphMode": "area",
                "justifyMode": "auto",
                "orientation": "horizontal",
                "percentChangeColorMode": "standard",
                "reduceOptions": {
                  "calcs": [
                    "lastNotNull"
                  ],
                  "fields": "",
                  "values": false
                },
                "showPercentChange": false,
                "textMode": "auto",
                "wideLayout": true
              },
              "fieldConfig": {
                "defaults": {
                  "unit": "percent",
                  "decimals": 0,
                  "min": 0,
                  "max": 100,
                  "thresholds": {
                    "mode": "absolute",
                    "steps": [
                      {
                        "value": 0,
                        "color": "rgba(245, 54, 54, 0.9)"
                      },
                      {
                        "value": 10,
                        "color": "rgba(237, 129, 40, 0.89)"
                      },
                      {
                        "value": 50,
                        "color": "rgba(50, 172, 45, 0.97)"
                      }
                    ]
                  }
                },
                "overrides": []
              }
            }
          }
        }
      }
    },
    "layout": {
      "kind": "GridLayout",
      "spec": {
        "items": [
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 0,
              "width": 6,
              "height": 3,
              "element": {
                "kind": "ElementReference",
                "name": "panel-19"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 6,
              "y": 0,
              "width": 6,
              "height": 3,
              "element": {
                "kind": "ElementReference",
                "name": "panel-25"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 0,
              "width": 6,
              "height": 3,
              "element": {
                "kind": "ElementReference",
                "name": "panel-26"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 18,
              "y": 0,
              "width": 6,
              "height": 3,
              "element": {
                "kind": "ElementReference",
                "name": "panel-9"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 3,
              "width": 24,
              "height": 7,
              "element": {
                "kind": "ElementReference",
                "name": "panel-2"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 10,
              "width": 24,
              "height": 7,
              "element": {
                "kind": "ElementReference",
                "name": "panel-18"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 17,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-6"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 17,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-29"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 25,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-24"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 25,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-20"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 33,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-27"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 33,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-28"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 41,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-21"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 41,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-22"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 49,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-23"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 49,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-30"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 0,
              "y": 57,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-31"
              }
            }
          },
          {
            "kind": "GridLayoutItem",
            "spec": {
              "x": 12,
              "y": 57,
              "width": 12,
              "height": 8,
              "element": {
                "kind": "ElementReference",
                "name": "panel-32"
              }
            }
          }
        ]
      }
    },
    "links": [],
    "liveNow": false,
    "preload": false,
    "tags": [
      "GrafanaCommunity"
    ],
    "timeSettings": {
      "timezone": "utc",
      "from": "now-1h",
      "to": "now",
      "autoRefresh": "30s",
      "autoRefreshIntervals": [
        "5s",
        "30s",
        "1m",
        "5m",
        "15m",
        "30m",
        "1h"
      ],
      "hideTimepicker": false,
      "weekStart": "monday",
      "fiscalYearStartMonth": 0
    },
    "title": "Prometheus system",
    "variables": [
      {
        "kind": "IntervalVariable",
        "spec": {
          "name": "interval",
          "query": "1s,5s,1m,5m,1h,6h,1d",
          "current": {
            "text": "$__auto",
            "value": "$__auto"
          },
          "options": [
            {
              "selected": false,
              "text": "1s",
              "value": "1s"
            },
            {
              "selected": false,
              "text": "5s",
              "value": "5s"
            },
            {
              "selected": false,
              "text": "1m",
              "value": "1m"
            },
            {
              "selected": false,
              "text": "5m",
              "value": "5m"
            },
            {
              "selected": false,
              "text": "1h",
              "value": "1h"
            },
            {
              "selected": false,
              "text": "6h",
              "value": "6h"
            },
            {
              "selected": false,
              "text": "1d",
              "value": "1d"
            }
          ],
          "auto": true,
          "auto_min": "1s",
          "auto_count": 200,
          "refresh": "onTimeRangeChanged",
          "label": "Interval",
          "hide": "dontHide",
          "skipUrlSync": false
        }
      },
      {
        "kind": "CustomVariable",
        "spec": {
          "name": "tag",
          "query": "instance, alias",
          "current": {
            "text": "instance",
            "value": "instance"
          },
          "options": [
            {
              "selected": true,
              "text": "instance",
              "value": "instance"
            },
            {
              "selected": false,
              "text": "alias",
              "value": "alias"
            }
          ],
          "multi": false,
          "includeAll": false,
          "hide": "dontHide",
          "skipUrlSync": false,
          "allowCustomValue": true
        }
      },
      {
        "kind": "QueryVariable",
        "spec": {
          "name": "host",
          "current": {
            "text": "prometheus-server-node",
            "value": "prometheus-server-node"
          },
          "label": "Server Hostname",
          "hide": "dontHide",
          "refresh": "onDashboardLoad",
          "skipUrlSync": false,
          "query": {
            "kind": "DataQuery",
            "group": "prometheus",
            "version": "v0",
            "spec": {
              "qryType": 1,
              "query": "label_values(job)",
              "refId": "PrometheusVariableQueryEditor-VariableQuery"
            }
          },
          "regex": "",
          "sort": "disabled",
          "definition": "label_values(job)",
          "options": [],
          "multi": false,
          "includeAll": false,
          "allowCustomValue": false
        }
      }
    ],
    "preferences": {
      "layout": {
        "kind": "GridLayout",
        "spec": {
          "items": []
        }
      }
    }
  }
}
