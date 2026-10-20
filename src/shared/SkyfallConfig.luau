-- ReplicatedStorage > SkyfallConfig. Change the course version after changing ranked routes.
return {
    Version = "Rush_v9",
    SectionLength = 96,
    CheckpointEvery = 2,
    WalkSpeed = 20,
    JumpPower = 50,
    FallPenalty = 3,
    StartingCoins = 125,
    CoinValue = 5,
    PrototypeSkipEnabled = true, -- Free prototype. No purchase prompt or Robux charge.
    SkipProductId = 0, -- Reserved for a future developer product / ProcessReceipt integration.
    ProfileStore = "Skyfall_Profile_v3",
    RecordStorePrefix = "Skyfall_Rush_v9_",
    Levels = {
        {Title="The Ascent", Difficulty="EASY", Sections=8, X=0, Color=Color3.fromRGB(70,235,220), Summary="Learn precise jumps, ghost timing, boulder hops and switchback bridges.", Patterns={"Jumps","Hurdles","Slalom","Phase","BoulderHop","Switchback","Balance","Spinners"}},
        {Title="Ember Ruins", Difficulty="MEDIUM", Sections=8, X=4096, Color=Color3.fromRGB(255,173,82), Summary="Navigate a ruin maze, cross a curved bridge, climb the terraces and time the foundry.", Patterns={"Crumble","Maze","Conveyor","ArchCrossing","TerraceClimb","Spring","Alternating","Crusher"}},
        {Title="Stormworks", Difficulty="HARD", Sections=8, X=8192, Color=Color3.fromRGB(160,128,255), Summary="Board platform relays, ride vertical lifts and cross the wind walk.", Patterns={"MovingRelay","Ferry","Elevator","Alternating","WindSwitchback","Spinners","Elevator","MovingRelay"}},
        {Title="Solar Collapse", Difficulty="EXPERT", Sections=8, X=12288, Color=Color3.fromRGB(255,100,124), Summary="Combine phase timing, orbit sweepers, ferries and a rising reactor finale.", Patterns={"Crumble","Phase","Orbit","Crusher","Ferry","TerraceClimb","Balance","Finale"}},
    },
    Catalog = {
        {Id="Ion", Name="Ion Wake", Kind="Trail", Price=75, Color=Color3.fromRGB(70,235,220), Description="A crisp cyan ribbon."},
        {Id="Ember", Name="Ember Streak", Kind="Trail", Price=150, Color=Color3.fromRGB(255,155,60), Description="A warm orange trail."},
        {Id="Violet", Name="Violet Surge", Kind="Trail", Price=250, Color=Color3.fromRGB(175,125,255), Description="Leave a violet arc."},
        {Id="Solar", Name="Solar Ribbon", Kind="Trail", Price=500, Color=Color3.fromRGB(255,225,100), Description="A gold speedrun signature."},
        {Id="FrostAura", Name="Frost Aura", Kind="Aura", Price=350, Color=Color3.fromRGB(100,220,255), Description="A soft icy character outline."},
        {Id="SolarHalo", Name="Solar Halo", Kind="Aura", Price=650, Color=Color3.fromRGB(255,205,90), Description="A floating golden halo."},
    },
}


