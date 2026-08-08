class SolStoryState : Inventory
{
    int ContractVersion;
    int CurrentObjective;
    Array<int> FiredEvents;
    Array<int> CompletedObjectives;
    Array<int> SeenSubtitles;
    Array<int> HeardRadio;

    Default
    {
        Inventory.MaxAmount 1;
        +Inventory.Undroppable
    }

    override void AttachToOwner(Actor other)
    {
        Super.AttachToOwner(other);
        if (ContractVersion == 0)
        {
            ContractVersion = SolStoryIds.Contract;
        }
    }

    bool HasEvent(int id)
    {
        for (int i = 0; i < FiredEvents.Size(); i++)
        {
            if (FiredEvents[i] == id)
            {
                return true;
            }
        }
        return false;
    }

    bool RecordEvent(int id)
    {
        if (!SolStoryIds.IsValid(id) || HasEvent(id))
        {
            return false;
        }
        FiredEvents.Push(id);
        return true;
    }

    bool IsObjectiveComplete(int id)
    {
        for (int i = 0; i < CompletedObjectives.Size(); i++)
        {
            if (CompletedObjectives[i] == id)
            {
                return true;
            }
        }
        return false;
    }

    bool StartObjective(int id)
    {
        if (!SolStoryIds.IsValid(id) || IsObjectiveComplete(id))
        {
            return false;
        }
        CurrentObjective = id;
        return true;
    }

    bool CompleteObjective(int id)
    {
        if (!SolStoryIds.IsValid(id) || IsObjectiveComplete(id))
        {
            return false;
        }
        CompletedObjectives.Push(id);
        if (CurrentObjective == id)
        {
            CurrentObjective = 0;
        }
        return true;
    }

    bool HasSeenSubtitle(int id)
    {
        for (int i = 0; i < SeenSubtitles.Size(); i++)
        {
            if (SeenSubtitles[i] == id)
            {
                return true;
            }
        }
        return false;
    }

    bool RecordSubtitle(int id)
    {
        if (!SolStoryIds.IsValid(id) || HasSeenSubtitle(id))
        {
            return false;
        }
        SeenSubtitles.Push(id);
        return true;
    }

    bool HasHeardRadio(int id)
    {
        for (int i = 0; i < HeardRadio.Size(); i++)
        {
            if (HeardRadio[i] == id)
            {
                return true;
            }
        }
        return false;
    }

    bool RecordRadio(int id)
    {
        if (!SolStoryIds.IsValid(id) || HasHeardRadio(id))
        {
            return false;
        }
        HeardRadio.Push(id);
        return true;
    }
}
