
class NewNet_ClassicSniperRifle extends ClassicSniperRifle
    HideDropDown
	CacheExempt;

var TimeStamp T;
var MutUTComp M;

replication
{
    reliable if( Role<ROLE_Authority )
        NewNet_ServerStartFire;
}

function DisableNet()
{
    NewNet_ClassicSniperFire(FireMode[0]).bUseEnhancedNetCode = false;
    NewNet_ClassicSniperFire(FireMode[0]).PingDT = 0.00;
}

simulated function ClientStartFire(int mode)
{
    if (mode == 1)
    {
        FireMode[mode].bIsFiring = true;
        if( Instigator.Controller.IsA( 'PlayerController' ) )
            PlayerController(Instigator.Controller).ToggleZoom();
    }
    else
    {
        SuperClientStartFire(mode);
    }
}

simulated event SuperClientStartFire(int Mode)
{
    if(Level.NetMode!=NM_Client || !class'BS_xPlayer'.static.UseNewNet())
        super(Weapon).ClientStartFire(mode);
    else
        NewNet_ClientStartFire(mode);
}

simulated event NewNet_ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            if(T==None)
                foreach DynamicActors(class'TimeStamp', T)
                     break;

            NewNet_ServerStartFire(mode, T.ClientTimeStamp);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

function NewNet_ServerStartFire(byte Mode, float ClientTimeStamp)
{
    if(M==None)
        foreach DynamicActors(class'MutUTComp', M)
	        break;

    if(NewNet_ClassicSniperFire(FireMode[Mode])!=None)
    {
        NewNet_ClassicSniperFire(FireMode[Mode]).PingDT = M.ClientTimeStamp - ClientTimeStamp + 1.75*M.AverDT;
        NewNet_ClassicSniperFire(FireMode[Mode]).bUseEnhancedNetCode = true;
    }

    ServerStartFire(Mode);
}

DefaultProperties
{
     PickupClass=Class'UTCompv18.NewNet_ClassicSniperRiflePickup'
     FireModeClass(0)=class'UTCompv18.NewNet_ClassicSniperFire'
}
