package Kernel.ProjectHolder.CoworkerManager
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Kernel.ProjectHolder.ProjectManager;
	
	import GUI.Assembly.FlexibleLayoutObject;
	import GUI.Assembly.ContainerBox;
	import GUI.Assembly.LabelTextField;
	import GUI.Assembly.SkinBox;
	import GUI.Assembly.SkinTextField;
	import GUI.Assembly.TextInput;
	import GUI.Scroll.Scroll;
	
	import UserInterfaces.IvyBoard.IvyPanels.ProjectDetailPanel;
	
	import UserInterfaces.ReminderManager.ReminderManager;
	import UserInterfaces.LoginAccount.AuthorizedURLLoader;
	
	
	
	public class CoWorkerPanel extends Sprite implements FlexibleLayoutObject{
		
		private var Align:int=5;
		
		private var back:SkinBox=new SkinBox();
		private var back2:SkinBox=new SkinBox();
		
		private var workerSpace:Array=[];
		private var scroller:ContainerBox=new ContainerBox();
		private var scroller2:ContainerBox=new ContainerBox();
		private var scroll:Scroll=new Scroll(scroller);
		private var scroll2:Scroll=new Scroll(scroller2);
		
		private var hint2:LabelTextField=new LabelTextField("Search and add Members:");
		private var hint:LabelTextField=new LabelTextField("Current Members:");
		private var hint3:SkinTextField=new SkinTextField("Members can add, delete or modify any object in this project. But they can not edit its name, members or existence.");
		
		public var Width:Number;
		public var Height:Number;
		
		private var searchBox:TextInput=new TextInput(true);
		private var HalfWidth:Number;
		
		public function CoWorkerPanel(){		
			
			addChild(hint2);
			addChild(searchBox);
			addChild(back2);
			addChild(scroll2);
			
			addChild(hint)
			addChild(back);
			addChild(scroll);
			
			addChild(hint3);
			
			setSize(550,300);
			
			searchBox.hintText="Type name"
			
			searchBox.addEventListener(Event.CHANGE,search);
			
		}
		
		
		public function flushWorkerList():void{
			
			workerSpace=[];
			for(var i:int=0;i<ProjectManager.co_works.length;i++){
				var worker:WorkerInfo=ProjectManager.co_works[i];
				var cw:CoWorkerInfo=new CoWorkerInfo(CoWorkerInfo.INFO_REMOVE,worker)
				workerSpace.push(cw);
				
				cw.addEventListener("clicked",function (e):void{
					removecoworker(e.target.workerinfo);
				});
			}
			
			
			ProjectDetailPanel.refreshDetail();
			redraw();
		}
		
		private function search(e):void{
			
			var urlV:URLVariables=new URLVariables();
			urlV.name=searchBox.text;
			
			var urequest:URLRequest=new URLRequest(GlobalVaribles.PROJECT_SEARCH_USER);
			urequest.method="post";
			urequest.data=urlV;
			
			var loader:AuthorizedURLLoader=new AuthorizedURLLoader();
			loader.load(urequest);
			
			loader.addEventListener(Event.COMPLETE,searchRes);
		}
		
		public function addcoworker(worker:WorkerInfo):void{
			
			var urequest:URLRequest=new URLRequest(GlobalVaribles.PROJECT_COLLABORATOR+worker.ID+"/");
			urequest.method="post";
			
			var loader:AuthorizedURLLoader=new AuthorizedURLLoader();
			loader.load(urequest);
			
			loader.addEventListener(Event.COMPLETE,function (e):void{
				for (var j:int = 0; j < ProjectManager.co_works.length; j++) {
					if((ProjectManager.co_works[j] as WorkerInfo).ID==worker.ID){
						ReminderManager.remind("Member already exist");
						return;
					}	
				}
				ProjectManager.co_works.push(worker);
				
				flushWorkerList();
				
				scroll.rollToButtom();
			});
		}
		
		public function removecoworker(worker:WorkerInfo):void{
			
			var urequest:URLRequest=new URLRequest(GlobalVaribles.PROJECT_COLLABORATOR+worker.ID+"/");
			urequest.method=URLRequestMethod.DELETE;
			
			var loader:AuthorizedURLLoader=new AuthorizedURLLoader();
			loader.load(urequest);
			
			loader.addEventListener(Event.COMPLETE,function (e):void{
				if(loader.data.indexOf("success")!=-1){
					for (var i:int = 0; i < ProjectManager.co_works.length; i++) 
					{
						if(ProjectManager.co_works[i]==worker){
							ProjectManager.co_works.splice(i,1);
							flushWorkerList();
							ReminderManager.remind("Delete Success");
							return;
						}
					}
				}else{
					ReminderManager.remind("Delete Failed");
				}
			});
		}
		
		public function searchRes(e):void{
			
			var rawRes:Array=JSON.parse(e.target.data).results;
			
			scroller2.removeChildren();
			
			for (var i:int = 0; i < rawRes.length; i++){
				var cw:CoWorkerInfo=new CoWorkerInfo(CoWorkerInfo.INFO_ADD,new WorkerInfo(rawRes[i].username,rawRes[i].id,new BitmapData(10,10)));
				
				cw.addEventListener("clicked",function (e):void{
					
					for (var j:int = 0; j < ProjectManager.co_works.length; j++) {
						if((ProjectManager.co_works[j] as WorkerInfo).ID==e.target.workerinfo.ID){
							ReminderManager.remind("Member already exist");
							return;
						}	
					}
					addcoworker(e.target.workerinfo);
				});
				
				cw.x=Align;
				
				cw.y=i*65+5;
				
				cw.setSize(HalfWidth);
				
				scroller2.addChild(cw);
				
			}
			scroller2.setSize(HalfWidth,rawRes.length*65+5);
			scroll2.negativeRedraw();
		}
		
		private function redraw():void
		{
			scroller.removeChildren();
			for (var i:int = 0; i < workerSpace.length; i++) {
				
				workerSpace[i].x=Align;
				
				workerSpace[i].y=i*65+5;
				
				workerSpace[i].setSize(HalfWidth-10);
				
				scroller.addChild(workerSpace[i]);
				
			}
			
			scroller.setSize(HalfWidth,workerSpace.length*65+5);
			scroll.negativeRedraw();
		}
		
		public function setSize(w:Number, h:Number):void
		{
			
			
			Height=h;
			Width=w;
			
			HalfWidth=Width/2-10;
			
			back2.setSize(HalfWidth+10,h-55);
			scroll2.setSize(HalfWidth+10,h-55);
			
			searchBox.setSize(HalfWidth+10,26);
			
			searchBox.y=25;
			
			back2.y=55;
			scroll2.y=55;
			
			back.setSize(HalfWidth,h-25);
			scroll.setSize(HalfWidth,h-25);
			
			hint.x=back.x=scroll.x=Width/2+8;
			back.y=scroll.y=25;
			
			hint3.setSize(w);
			
			hint3.y=Height;
			
			Height+=hint3.height;
			
			redraw();
			
		}
		
	}
}

