import com.GameInterface.Chat;
import com.GameInterface.Claim;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;

class com.fox.DailyPrevention.DailyPrevention
{
	private var m_Daily_Login:DistributedValue;
	public static function main(swfRoot:MovieClip):Void
	{
		var m_mod = new DailyPrevention(swfRoot);
		swfRoot.onLoad = function() {m_mod.Load()};
		swfRoot.onUnload = function() {m_mod.Unload()};
	}

	public function DailyPrevention()
	{
		m_Daily_Login = DistributedValue.Create("dailyLogin_window");
	}

	public function Load()
	{
		m_Daily_Login.SignalChanged.Connect(HookClaim, this);
		HookClaim(m_Daily_Login);
		Claim.SignalRewardsUpdated.Connect(AutoClaim, this);
		AutoClaim();
	}

	static function NameMatch()
	{
		var characters:Array = DistributedValueBase.GetDValue("DailyPrevention_Character").split(",");
		var name = Character.GetClientCharacter().GetName();
		for (var y in characters)
		{
			if (characters[y] == name) return true;
		}
	}

	static function IsEvent(trackNum)
	{
		var trackLength:Number = Claim.GetRewardTrackLength(trackNum);
		return trackLength != 28 && trackNum != 0;
	}

	private function AutoClaim()
	{
		if (DistributedValueBase.GetDValue("DailyPrevention_AutoClaim"))
		{
			// Try to claim rewards
			var m_NumTracks = Claim.GetNumRewardTracks();
			for (var i = 0; i < m_NumTracks; i++)
			{
				if (Claim.RewardAvailable(i))
				{
					if (NameMatch() || IsEvent(i))
					{
						Claim.ClaimReward(i);
					}
				}
			}
			// Force update topbar icon?
			// It should get updated by one of the Claim Signals?
			//_root.mainmenuwindow.UpdateDailyRewardStatus()
			// Check if there are unclaimed rewards
			var claimAvailable:Boolean = false;
			for (var i:Number = 0; i < Claim.GetNumRewardTracks(); i++)
			{
				if (Claim.RewardAvailable(i))
				{
					if (NameMatch() || IsEvent())
					{
						claimAvailable = true;
						break;
					}
				}
			}
			// If there are still rewards for some reason keep window open,otherwise close it
			if (!claimAvailable && m_Daily_Login.GetValue())
			{
				m_Daily_Login.SetValue(false);
			}
		}
	}

	private function HookClaim(dv:DistributedValue)
	{
		if (!dv.GetValue()) return;
		if(_global.DailyHook) return
		if (!_global.GUI.DailyLogin.Skin){
			setTimeout(Delegate.create(this, HookClaim), 100, dv);
			return
		}
		var f = function()
		{
			if (!DailyPrevention.IsEvent(this.m_TrackNum))
			{
				if (DailyPrevention.NameMatch())
				{
					arguments.callee.base.apply(this, arguments);
				}
				else if (Key.isDown(Key.CONTROL))
				{
					arguments.callee.base.apply(this, arguments)
				}
				else
				{
					Chat.SignalShowFIFOMessage.Emit("DailyPrevention: Claiming blocked on this character, hold Ctrl to override", 0);
				}
			}
			else
			{
				arguments.callee.base.apply(this, arguments)
			}
		}
		f.base = _global.GUI.DailyLogin.Skin.prototype.ClaimReward;
		_global.GUI.DailyLogin.Skin.prototype.ClaimReward = f;
		_global.DailyHook = true;
	}
	public function Unload()
	{
		m_Daily_Login.SignalChanged.Disconnect(HookClaim, this);
		Claim.SignalRewardsUpdated.Disconnect(AutoClaim, this);
	}
}