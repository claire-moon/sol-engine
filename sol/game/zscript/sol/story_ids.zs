class SolStoryIds : Object
{
    const Contract = 1;
    const MinId = 1;
    const MaxId = 65535;

    static bool IsValid(int id)
    {
        return id >= MinId && id <= MaxId;
    }
}
