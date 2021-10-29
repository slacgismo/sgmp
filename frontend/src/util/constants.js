export default Object.freeze({
    server: "http://54.176.249.126",
    timeFormat: {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    },
    roles: Object.freeze({ Admin: "admin", Researcher: "researcher", Visitor: "visitor" }),
    units: Object.freeze({ Power: "kW", Energy: "kWh", Percentage: "%", Seconds: "sec" }),
    // Mapping between energy type and formula
    formula: Object.freeze({
        Solar: "solar",
        Grid: "gridpower",
        Battery: "battery",
        BatteryCharging: "battery_charging",
        BatteryDischarging: "battery_discharging",
        SOC: "soc",
        EV: "ev",
        Load: "load",
        Frequency: "egauge.A.L1_Frequency",
        Voltage1: "egauge.A.L1_Voltage",
        Voltage2: "egauge.A.L2_Voltage"
    }),
    sources: Object.freeze({ Battery: "sonnen" }),
    chartTypes: Object.freeze({ Column: "column", Line: "line", Donut: "donut" })
})