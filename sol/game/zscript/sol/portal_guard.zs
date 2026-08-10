class SolPlayer : DoomPlayer
{
    override bool CanCrossLine(Line crossing, Vector3 next)
    {
        if (!Super.CanCrossLine(crossing, next))
        {
            return false;
        }

        if (crossing == null ||
            crossing.Special != 156 ||
            crossing.Args[2] != LinePortal.PORTT_LINKED ||
            (crossing.Args[0] != 9001 && crossing.Args[0] != 9002))
        {
            return true;
        }

        double moveX = next.X - Pos.X;
        double moveY = next.Y - Pos.Y;
        Vector2 forward = AngleToVector(Angle, 1.0);

        if (moveX * forward.X + moveY * forward.Y < 0.0)
        {
            return false;
        }

        return true;
    }
}
