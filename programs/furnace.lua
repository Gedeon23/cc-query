local log = require("log")
local basalt = require("basalt")

manager = {
    name = "",
    furnaces = {peripheral.find("minecraft:furnace")},
    input = peripheral.find("minecraft:barrel"),
    output = peripheral.find("minecraft:chest"),
    current_job = nil,
    job_queue = {}
}

function manager:updateJobs()
    local input_inv = self.input.list()
    if self.current_job then
        self.current_job.toBeSmelted = 0
    end

    for slot, item in pairs(input_inv) do
        if item.name == self.current_job.name then
            self.current_job.toBeSmelted = self.current_job.toBeSmelted + item.count
        elseif ~self.job_queue[item.name] then
            self.job_queue[item_name] = { total = item.count, location = {}}
            self.job_queue[item_name].location[slot] = item.count
        else
            self.job_queue[item_name].total = self.job_queue[item_name].total + item.count
            self.job_queue[item_name].location[slot] = item.count
        end
    end
end

function manager:startJob(item_name)
    if self.job_queue[item_name] then
        self.current_job = table.remove(self.job_queue, item_name)
        self.current_job[name] = item_name
        self.current_job.toBeSmelted = self.current_job.total
        return true
    else
        return false
    end
end

function manager:smelt()
    items_per_furnace = self.current_job.toBeSmelted / #self.furnaces
    for i, furance in pairs()
