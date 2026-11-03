--!strict
-- R1 master plan. X/Z are studs; route node Y is the walking surface center.
local Layout = {
    GeneratorId = "CAPY-M01A",
    Phase = "POLISH-1",
    Zones = {
        {Id = "A", Name = "Capybara Habitat", Center = Vector3.new(-190, 0.6, -125), Radius = 70},
        {Id = "B", Name = "Animal Walkway", Center = Vector3.new(-55, 0.6, -125), Radius = 43},
        {Id = "C", Name = "Visitor Plaza", Center = Vector3.new(75, 0.9, -125), Radius = 45},
        {Id = "D", Name = "Zoo Security", Center = Vector3.new(210, 0.6, -125), Radius = 46},
        {Id = "E", Name = "Maintenance Yard", Center = Vector3.new(-195, 0.6, 50), Radius = 57},
        {Id = "F", Name = "Tropical Garden", Center = Vector3.new(10, 0.8, 50), Radius = 70},
        {Id = "G", Name = "Grand Zoo Entrance", Center = Vector3.new(205, 0.6, 178), Radius = 52},
        {Id = "H", Name = "Forest Perimeter", Center = Vector3.new(-195, 0.6, 180), Radius = 49},
    },
    -- Quadratic Bezier controls create continuous, gently curved walking routes.
    Routes = {
        {From = "A", To = "B", Width = 18, Control = Vector3.new(-120, 0.6, -125)},
        {From = "B", To = "C", Width = 24, Control = Vector3.new(12, 1.0, -98)},
        {From = "C", To = "D", Width = 22, Control = Vector3.new(145, 0.7, -105)},
        {From = "A", To = "E", Width = 16, Control = Vector3.new(-95, 0.7, 20),
            Via = Vector3.new(-104, 0.6, -125)},
        {From = "E", To = "F", Width = 20, Control = Vector3.new(-95, 1.0, 82)},
        {From = "C", To = "F", Width = 24, Control = Vector3.new(105, 1.1, -12)},
        {From = "D", To = "G", Width = 22, Control = Vector3.new(255, 0.7, 40)},
        {From = "F", To = "G", Width = 24, Control = Vector3.new(110, 0.8, 162)},
        {From = "E", To = "H", Width = 16, Control = Vector3.new(-170, 0.7, 118)},
        {From = "H", To = "F", Width = 16, Control = Vector3.new(-35, 0.8, 206)},
    },
    Spawn = Vector3.new(-218, 0.5, -115),
    Checkpoints = {
        {Id = "CP01", Position = Vector3.new(-204, 0.95, -115)},
        {Id = "CP02", Position = Vector3.new(89, 1.3, -125)},
        {Id = "CP03", Position = Vector3.new(218, 1.05, 179)},
    },
    -- Reserved R2 footprints are data, not obstructing placeholder cubes.
    Reservations = {
        {Id = "GardenPump", Center = Vector3.new(8, 0, -5), Size = Vector3.new(16, 12, 16)},
        {Id = "RangerMali", Center = Vector3.new(119, 0, -95), Size = Vector3.new(20, 14, 18)},
        {Id = "ForestPostcard", Center = Vector3.new(-222, 0, 150), Size = Vector3.new(20, 12, 16)},
        {Id = "HabitatShelter", Center = Vector3.new(-246, 0, -79), Size = Vector3.new(36, 24, 28)},
        {Id = "CanopyWalk", Center = Vector3.new(-59, 0, -163), Size = Vector3.new(40, 24, 24)},
        {Id = "PlazaKiosks", Center = Vector3.new(107, 0, -166), Size = Vector3.new(30, 22, 24)},
        {Id = "SecurityOffice", Center = Vector3.new(215, 0, -166), Size = Vector3.new(52, 28, 34)},
        {Id = "MaintenanceShed", Center = Vector3.new(-225, 0, 14), Size = Vector3.new(44, 24, 30)},
        {Id = "GardenSala", Center = Vector3.new(63, 0, 48), Size = Vector3.new(30, 26, 28)},
        {Id = "TicketKiosks", Center = Vector3.new(162, 0, 200), Size = Vector3.new(22, 24, 24)},
        {Id = "ForestLookout", Center = Vector3.new(-235, 0, 177), Size = Vector3.new(27, 27, 26)},
    },
    FutureRoutes = {
        {Id = "MAIN_GATE", Position = Vector3.new(205, 0, 235), Width = 34},
        {Id = "MAINTENANCE_TUNNEL", Position = Vector3.new(-282, 0, 70), Width = 22},
        {Id = "FENCE_ESCAPE", Position = Vector3.new(-255, 0, -214), Width = 18},
    },
}
return Layout
