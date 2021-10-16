export default Object.freeze({
    server: "http://ec2-54-176-53-197.us-west-1.compute.amazonaws.com:5000",
    roles: Object.freeze({ Admin: "admin", Researcher: "researcher", Visitor: "visitor" }),
    units: Object.freeze({ Power: "kW", Energy: "kWh", Percentage: "%", Seconds: "sec" }),
    chartTypes: Object.freeze({ Column: "column", Line: "line", Donut: "donut" })
})