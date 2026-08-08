class SolBootstrap : EventHandler
{
    void EnsureStoryState(int playerNumber)
    {
        if (playerNumber < 0 || playerNumber >= MAXPLAYERS || !playerInGame[playerNumber])
        {
            return;
        }

        Actor pawn = players[playerNumber].mo;
        if (pawn == null)
        {
            return;
        }

        class<Inventory> storyType = "SolStoryState";
        if (pawn.FindInventory(storyType) == null)
        {
            pawn.GiveInventoryType(storyType);
        }
    }

    override void WorldLoaded(WorldEvent event)
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            EnsureStoryState(i);
        }
        Console.Printf("SOL v0.2.0 story foundation runtime loaded");
    }

    override void PlayerEntered(PlayerEvent event)
    {
        EnsureStoryState(event.PlayerNumber);
    }

    override void PlayerSpawned(PlayerEvent event)
    {
        EnsureStoryState(event.PlayerNumber);
    }
}
