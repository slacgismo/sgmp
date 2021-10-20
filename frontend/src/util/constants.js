export default Object.freeze({
    server: "http://ec2-54-176-53-197.us-west-1.compute.amazonaws.com:5000",
    roles: Object.freeze({ Admin: "admin", Researcher: "researcher", Visitor: "visitor" }),
    units: Object.freeze({ Power: "kW", Energy: "kWh", Percentage: "%", Seconds: "sec" }),
    // Mapping between energy type and formula
    formula: Object.freeze({
        Solar: "egauge.A.Solar",
        Battery: "sonnen.status.Pac_total_W/1000",
        BatteryCharging: "-neg(sonnen.status.Pac_total_W/1000)",
        BatteryDischarging: "pos(sonnen.status.Pac_total_W/1000)",
        SOC: "sonnen.battery.battery_status.relativestateofcharge",
        EV: "-egauge.A.EV",
        Load: "egauge.A.SubPanel",
        Frequency: "egauge.A.L1_Frequency",
        Voltage1: "egauge.A.L1_Voltage",
        Voltage2: "egauge.A.L2_Voltage"
    }),
    chartTypes: Object.freeze({ Column: "column", Line: "line", Donut: "donut" })
})