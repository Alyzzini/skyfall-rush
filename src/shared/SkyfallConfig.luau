-- ReplicatedStorage > SkyfallConfig. Change the course version after changing ranked routes.
return {
    Version = "Rush_v3",
    SectionLength = 96,
    CheckpointEvery = 4,
    WalkSpeed = 22,
    JumpPower = 54,
    FallPenalty = 3,
    StartingCoins = 125,
    CoinValue = 5,
    PrototypeSkipEnabled = true, -- Free prototype. No purchase prompt or Robux charge.
    SkipProductId = 0, -- Reserved for a future developer product / ProcessReceipt integration.
    ProfileStore = "Skyfall_Profile_v3",
    RecordStorePrefix = "Skyfall_Rush_v3_",
    Levels = {
        {Title="The Ascent", Difficulty="EASY", Sections=8, X=0, Color=Color3.fromRGB(70,235,220), Summary="Learn momentum jumps, hurdle runs, ghost platforms, and slalom walls.", Patterns={"Jumps","Hurdles","Slalom","Phase","Crumble","Ferry","Balance","Spinners"}},
        {Title="Ember Ruins", Difficulty="MEDIUM", Sections=12, X=4096, Color=Color3.fromRGB(255,173,82), Summary="Chain crumbling steps, crosswinds, spring jumps, and sliding gates.", Patterns={"Crumble","Slalom","Conveyor","Slide","Jumps","Spring","Phase","Crusher","Ferry","Hurdles","Balance","Spinners"}},
        {Title="Stormworks", Difficulty="HARD", Sections=16, X=8192, Color=Color3.fromRGB(160,128,255), Summary="Read collision changes, ride moving ferries, and time the crusher corridors.", Patterns={"Phase","Ferry","Balance","Crusher","Conveyor","Spinners","Crumble","Slide","Spring","Phase","Slalom","Hurdles","Ferry","Crusher","Balance","Spinners"}},
        {Title="Solar Collapse", Difficulty="EXPERT", Sections=20, X=12288, Color=Color3.fromRGB(255,100,124), Summary="The longest route: tighter landings, double sweepers, rapid phases, and mixed machinery.", Patterns={"Crumble","Phase","Spinners","Crusher","Ferry","Conveyor","Balance","Slide","Spring","Slalom","Phase","Hurdles","Crusher","Crumble","Ferry","Spinners","Conveyor","Balance","Slide","Spinners"}},
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

