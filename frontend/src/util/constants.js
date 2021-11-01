export default Object.freeze({
    server: "http://54.176.249.126",
    timeFormat: {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    },
    roles: Object.freeze({ Admin: "admin", Researcher: "researcher", Visitor: "visitor" }),
    units: Object.freeze({ Power: "kW", Energy: "kWh", Percentage: "%", Number: "", Millisecond: "ms" }),
    // Mapping between energy type and formula
    analytics: Object.freeze({
        Solar: "solar",
        Grid: "gridpower",
        Battery: "battery",
        BatteryCharging: "battery_charging",
        BatteryDischarging: "battery_discharging",
        SOC: "soc",
        EV: "ev",
        EVChargingCount: "ev_event_count",
        EVChargingDuration: "ev_charge_duration",
        Load: "load",
        Frequency: "l1_frequency",
        Voltage1: "l1_voltage",
        Voltage2: "l2_voltage"
    }),
    deviceTypes: Object.freeze(['sonnen', 'egauge', 'powerflex']),
    sources: Object.freeze({ Battery: "sonnen" }),
    chartTypes: Object.freeze({ Column: "column", Line: "line", Donut: "donut" })
})