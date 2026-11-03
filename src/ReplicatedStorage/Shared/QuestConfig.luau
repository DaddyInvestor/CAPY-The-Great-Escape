--!strict
-- A complete session-only introduction, not the future full escape campaign.
return {
    Title = "Mango's Morning Rescue",
    Steps = {
        {Id="FEED", Title="Feed Mango", Hint="The capy feeder is beside your habitat. Hold the prompt to offer breakfast.",
            Position=Vector3.new(-238, 2, -133), Action="Offer breakfast", Object="Mango's feeder", Hold=0.6,
            Response="Mango: prrr! Breakfast approved. The garden pump needs a helping paw."},
        {Id="PUMP", Title="Restore the garden pump", Hint="Follow the sandy paths toward the garden. Look for the blue hand pump.",
            Position=Vector3.new(8, 3, -5), Action="Prime the pump", Object="Garden water pump", Hold=1.4,
            Response="Water is flowing! Find Ranger Mali near the visitor plaza for your trail pass."},
        {Id="RANGER", Title="Meet Ranger Mali", Hint="Mali is on the east side of the visitor plaza, wearing a green hat.",
            Position=Vector3.new(119, 3, -95), Action="Talk to Mali", Object="Ranger Mali", Hold=0,
            Response="Mali: You saved Mango's morning! Take this pass to the grand entrance."},
        {Id="EXIT", Title="Use your trail pass", Hint="Follow the main promenade to the grand entrance. Present your pass at the gate.",
            Position=Vector3.new(205, 4, 228), Action="Present trail pass", Object="Grand entrance", Hold=0.5,
            Response="Trail complete! The gate is open. Keep exploring for the hidden forest postcard."},
    },
    Secret = {Id="POSTCARD", Position=Vector3.new(-222, 3, 150), Action="Collect forest postcard", Object="A little forest secret", Hold=0.3},
    InteractionDistance = 10,
    Cooldown = 0.8,
}
