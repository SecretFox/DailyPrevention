import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;

class com.fox.DailyPrevention.DailyPrevention 
{
	static var m_mod:DailyPrevention;
	private var LoginRewardsDval:DistributedValue;
	public static function main(swfRoot:MovieClip):Void	{
		var m_mod = new DailyPrevention(swfRoot);
		swfRoot.onLoad = function(){m_mod.Load()};
		swfRoot.onUnload = function(){m_mod.Unload()};
	}

	public function DailyPrevention(swfRoot:MovieClip) {
		m_mod = this;
	}

	public function Load(){
		LoginRewardsDval = DistributedValue.Create("dailyLogin_window");
		LoginRewardsDval.SignalChanged.Connect(HookClaim, this);
		HookClaim(LoginRewardsDval);
	}
	private function ClaimReward(){
		if (this["m_TrackLength"] == 28 && this["m_TrackNum"] == 0){
			var characters:Array = DistributedValueBase.GetDValue("DailyPrevention_Character").split(",");
			var name = Character.GetClientCharacter().GetName();
			for (var i in characters){
				if (characters[i] == name){
					this["_ClaimReward"]();
					return
				}
			}
			if (Key.isDown(Key.CONTROL)){
				this["_ClaimReward"]();
			} else {
				Chat.SignalShowFIFOMessage.Emit("DailyPrevention: Claiming blocked on this character, hold Ctrl to override", 0);
			}
		}
		else{
			this["_ClaimReward"]();
		}
	}
	
	//Hooks button on reward track change (events?)
	private function SetTrack(trackNum:Number, forceRefresh:Boolean){
		this["_SetTrack"](trackNum, forceRefresh);
		m_mod.HookClaim();
	}
	
	private function HookClaim(){
		if (LoginRewardsDval.GetValue()){
			var daily:MovieClip = _root.dailylogin.m_Window.m_Content;
			if (!daily.m_Skin.initialized){
				setTimeout(Delegate.create(this, HookClaim), 200);
				return
			}
			// Claim reward button hook
			if (!daily.m_Skin["_ClaimReward"] && daily.m_Skin["ClaimReward"]) {
				daily.m_Skin["_ClaimReward"] = daily.m_Skin["ClaimReward"];
				daily.m_Skin["ClaimReward"] = ClaimReward;
			}
			// rehook on reward track change (during events?)
			if (!daily["_SetTrack"]) {
				daily["_SetTrack"] = daily["SetTrack"];
				daily["SetTrack"] = SetTrack;
			}
		}
	}
	public function Unload(){
		LoginRewardsDval.SignalChanged.Disconnect(HookClaim, this);
	}
}