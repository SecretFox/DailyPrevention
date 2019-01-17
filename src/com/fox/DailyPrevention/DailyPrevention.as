import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.Game.Character;
import mx.utils.Delegate;

class com.fox.DailyPrevention.DailyPrevention 
{
	private var LoginRewardsDval:DistributedValue;
	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new DailyPrevention(swfRoot);
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
	}

	public function DailyPrevention() { }

	public function Load(){
		LoginRewardsDval = DistributedValue.Create("dailyLogin_window");
		LoginRewardsDval.SignalChanged.Connect(StopClaim, this);
		StopClaim(LoginRewardsDval);
	}
	private function ClaimReward(){
		if (this["m_TrackLength"] == 28 && !com.GameInterface.UtilsBase.GetGameTweak("Seasonal_SWL_Anniversary2018") && !this["m_TrackNum"]){
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
				Chat.SignalShowFIFOMessage.Emit("You must be holding Ctrl", 0);
			}
		}
		// Event
		else{
			this["_ClaimReward"]();
		}
	}
	
	public function StopClaim(dv:DistributedValue){
		if (dv.GetValue()){
			if (!_root.dailylogin.m_Window.m_Content.m_Skin["ClaimReward"]){
				setTimeout(Delegate.create(this, StopClaim), 200, dv);
				return
			}
			if (!_root.dailylogin.m_Window.m_Content.m_Skin["_ClaimReward"]){
				_root.dailylogin.m_Window.m_Content.m_Skin["_ClaimReward"] = _root.dailylogin.m_Window.m_Content.m_Skin["ClaimReward"];
				_root.dailylogin.m_Window.m_Content.m_Skin["ClaimReward"] = ClaimReward;
			}
		}
	}

	public function Unload(){
		LoginRewardsDval.SignalChanged.Disconnect(StopClaim, this);
	}
}