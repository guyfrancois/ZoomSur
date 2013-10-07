/**
 * @author guyf 26 oct. 2005
 */
 import org.aswing.util.SuspendedCall;
 import mx.video.*;
 import GraphicTools.BOverOutPress;
 import GraphicTools.I_Lecteur;
import org.aswing.Event;
import org.aswing.EventDispatcher;
import org.aswing.util.Delegate;
import Pt.Temporise;
import Pt.Tools.Clips;

 
class media.LecteurVideo extends EventDispatcher implements I_Lecteur {
	// evenements envoyés
	//TODO : problème pour lancer seek juste àprès l'initialisation de la vidéo :
	// LAG
	// détachement des écouteurs de la barre de lecture 
	
	static var ON_RESIZE:String="onResize";
	static var ON_STREAMUPDATE:String="onLoadUpdate";
	static var ON_HEADUPDATE:String="onHeadUpdate";
	static var ON_PAUSE:String="onPause";
	static var ON_PLAY:String="onPlay";
	static var ON_STOP:String="onStop";
	static var ON_END:String="onEnd";
	static var ON_INFO:String="onInfo";
	
	static var ALIGNTOP:Number=0;
	static var ALIGNLEFT:Number=0;
	static var ALIGNCENTER:Number=1;
	static var ALIGNBOTTOM:Number=2;
	static var ALIGNRIGHT:Number=2;
	
	static var SCALLIN:Number=0; // à l'interieur
	static var SCALLOUT:Number=1; // à l'exterieur
	static var SCALLNONE:Number=-1; // pas de re-scall
	
	
	private var maxWidth:Number;
	private var maxHeight:Number;
	private var xInit:Number;
	private var yInit:Number;

	private var hAlign:Number=ALIGNLEFT;
	private var vAlign:Number=ALIGNBOTTOM;
	private var scaleMode:Number=SCALLNONE;
	
	
	public static var prevInstance:I_Lecteur;
	
	private  var totalTime:Number;
	
	/**
	 * taille d'origine des barres progession et streaming
	 */

	/**
	 * taille du buffer
	 * un buffer trop grand semble empecher la lecture des metaData
	 * 			ce qui implique l'impossibilité de determinée le durée (duration)
	 * 			
	 */
	private var bufferTime:Number=1;
	
	
	
	private var audio:MovieClip;
	private var maVideo:Video;
	private var _nc:NetConnection;
    private var _ns:NetStream;
	
	
	private var fichierFlux:String;
	
	private var timer:Temporise;
	private var listenning:Boolean;
	
	public function getFichierFlux():String {
		return fichierFlux;
	}
	
	/**
	 * 
	 * 
	 * 
	 * exemple :
	 * GraphicTools.LecteurMedia(btn_pause, btn_play, btn_stop, maVideo, fichierFlux, controleur);
	 * 
	 */
	 public var son:Sound;	
	 public function LecteurVideo(maVideo:Video, fichierFlux:String, autoStart:Boolean,hAlign:Number,vAlign:Number,scaleMode:Number,width:Number,height:Number) {
		trace("LecteurVideo "+maVideo+" "+fichierFlux+" "+autoStart);
		 _isPlaying=false;
		if (hAlign!=undefined) this.hAlign=hAlign;
		if (vAlign!=undefined) this.vAlign=vAlign;
		if (scaleMode!=undefined) this.scaleMode=scaleMode;
		listenning=false;
		maxWidth=width;
		maxHeight=height;
		maVideo._x=0;
		maVideo._y=0;
		xInit=maVideo._x;
		yInit=maVideo._y;
		
		
		
		
		this.maVideo=maVideo;
		//parametres
		this.maVideo._visible=false;
		
        _nc = new NetConnection();
        _nc.connect(null);
        audio=maVideo._parent.createEmptyMovieClip('audio',1010);
        _ns = new NetStream(_nc);
        maVideo.attachVideo(_ns);
        audio.attachAudio(_ns);
		son=new Sound(audio)
		
		init_media(fichierFlux,autoStart);
		
	}
	/*
	function listen(evt:Object) {
		Log.addMessage("listen(evt)"+evt.type, Log.INFO,"GraphicTools.LecteurMedia");
		init_media();
	}
	*/
	public function clear(){
		trace("media.LecteurVideo.clear()");
		maVideo._visible=false;
		maVideo.clear();
	}
	
	private function init_media(fichierFlux:String,autoStart:Boolean):Void{
				
		        maTrace("GraphicTools.LecteurMedia.init_media("+fichierFlux+", "+autoStart+")");
				
				maTrace("fichier flux : "+fichierFlux);
				_ns.setBufferTime(bufferTime);
				//maVideo.bufferTime=bufferTime;
				
				if (fichierFlux!=undefined) {
					SuspendedCall.createCall(startVideo,this,[fichierFlux,autoStart],1);
					
				}
	}

	
	public function start(fichierFlux:String,autoPlay:Boolean,param2,param3){
		this.startVideo(fichierFlux,autoPlay==undefined?true:autoPlay);
	}
	
	private function startVideo(fichierFlux:String,autoStart:Boolean) {
		
		if (LecteurVideo.prevInstance!=this) {
            LecteurVideo.prevInstance.pause();
            LecteurVideo.prevInstance=this;
        }
		
		trace("GraphicTools.LecteurMedia.startVideo("+fichierFlux+", "+autoStart+")");
		
			
			trace("fichierFlux!=this.fichierFlux"+(fichierFlux!=this.fichierFlux)+" "+fichierFlux+" "+this.fichierFlux);
			if (fichierFlux!=this.fichierFlux) {
				clear();
				//maVideo._visible=false;
				this.fichierFlux=fichierFlux;
				//maVideo.contentPath=fichierFlux;
				if (autoStart) {
					//_ns.play("file://D:\\projet\\borzee2007\\"+Pt.Tools.Clips.convertURL(fichierFlux))
					_ns.play(Pt.Tools.Clips.convertURL(fichierFlux))
					// _isPlaying=true;
					 onPlaying()
                    
				} else {
					
					_ns.play(Pt.Tools.Clips.convertURL(fichierFlux))
					_ns.pause(true);
					//maVideo.load("file://"+Pt.Tools.Clips.convertURL(fichierFlux));
				}
			} else if (autoStart) {
				SuspendedCall.createCall(this.play,this,1);
				
			}
			initListener();
			trace(Pt.Tools.Clips.convertURL(fichierFlux));
			
			
	}

	private function playUpdate(){
		streamUpdate();
		playheadUpdate();
	}
	private function streamUpdate(){
		dispatchEvent(ON_STREAMUPDATE,new Event(this,ON_STREAMUPDATE,[_ns.bytesLoaded*100/_ns.bytesTotal]));
	}
	
	private function playheadUpdate() {
		
		dispatchEvent(ON_HEADUPDATE,new Event(this,ON_HEADUPDATE,[_ns.time*100/totalTime,_ns.time,totalTime]));
	
	}
	
	private function ready(eventObject:Object) {
		/*
		trace("GraphicTools.LecteurMedia.ready(eventObject) totalTime :"+maVideo.totalTime);
		for (var i : String in eventObject) {
			trace(i+" :"+eventObject[i]);
			
		}
		*/
		
	}
	/** famine */
	private function onBuffering (){
		/*
		trace("GraphicTools.LecteurMedia.buffering()");
		for (var i : String in eventObject) {
			trace(i+" :"+eventObject[i]);
			
		}
		*/
		//type:"buffering", state:eventState, playheadTime:e.playheadTime, vp:e.target._name
	}
	function onStopped(){
		
		timer.pause();
		trace("GraphicTools.LecteurMedia.stopped(eventObject):");
		trace("---eventObject.playheadTime "+_ns.time);
		trace("---maVideo.totalTime "+totalTime);
		
		
		
		
		if (totalTime !=undefined && _ns.time>=totalTime && _isPlaying) {
			_isPlaying=false;
			_ns.pause(true);
			//_ns.seek(0);
			dispatchEvent(ON_STOP,new Event(this,ON_STOP));
			dispatchEvent(ON_END,new Event(this,ON_END));
			Pt.Out.hx("media.LecteurVideo.onStopped(enclosing_method_arguments)"+ON_STOP+" "+ON_END);
		} else {
			_isPlaying=false;
			dispatchEvent(ON_STOP,new Event(this,ON_STOP));
			Pt.Out.hx("media.LecteurVideo.onStopped(enclosing_method_arguments)"+ON_STOP);
		}
		 
		
	}
	
	private function onSeekingEnd(){
        playheadUpdate();
	}
	private function onPlaying(){
		if (!_isPlaying) {
		 _isPlaying=true;
		timer.reprise();
		trace("GraphicTools.LecteurMedia.playing()")
		dispatchEvent(ON_PLAY,new Event(this,ON_PLAY));
		}
	
	}
	private function onPaused(eventObject:Object){
		trace("media.LecteurVideo.onPaused(eventObject)");
		
		_isPlaying=false;
		dispatchEvent(ON_PAUSE,new Event(this,ON_PAUSE));
	
	}
	private function maTrace(val:String):Void{
		trace(val);
		_root.tracer.text=val+"\r"+_root.tracer.text;
	}
	
	public function getTimeCode():Number{
		return Number(_ns.time);
	}
	
	public function duration():Number {
		return Number(totalTime);
	}
	
	public	function playAt(timeCode:Number) {
		trace("media.LecteurVideo.playAt("+timeCode+")");
		 _isPlaying=true;
		_ns.seek(timeCode);
		onPlaying();
	}
	
	public function play(){
		trace("media.LecteurVideo.play()");
		 if (LecteurVideo.prevInstance!=this) {
 		     LecteurVideo.prevInstance.pause();
          	 LecteurVideo.prevInstance=this;
        }
       if (totalTime !=undefined && _ns.time>=totalTime && !isPlaying()) {
       	_ns.seek(0);
       }
		_ns.pause(false);
		onPlaying();
		
				
	}
	
	public function pause(){
		if (_isPlaying) {
		_isPlaying=false;
		_ns.pause(true);
		onPaused();
		}
				
	}
	
	
	private var _isPlaying:Boolean
	public function isPlaying():Boolean{
		return _isPlaying;
	}
	
	
	public function stopAct(){

		_ns.pause(true);
		_ns.seek(0);
		onStopped();
				
	}
	
	public function stop(){

		_ns.pause(true);
		//_ns.seek(0);
		onStopped();
				
	}
	
	
	public function setGotoTo(pc:Number,autoPlay:Boolean){
		 if (LecteurVideo.prevInstance!=this) {
 		     LecteurVideo.prevInstance.pause();
          	 LecteurVideo.prevInstance=this;
        }
        _ns.seek(pc*totalTime/100)
		if (autoPlay) {
			
		
			_ns.pause(false);	
				onPlaying();
			
		} else {
			 _isPlaying=false;
			_ns.pause(true);
			onPaused();
		}
		
		maVideo._visible=true;
	}
	
	
	

	public function destroy(){
		trace("GraphicTools.LecteurMedia.destroy()");
		timer.pause();
		timer.destroy()
		_ns.close();
		fichierFlux=undefined;
        maVideo.clear();
        audio.removeMovieClip();
       
 	}
	

	
	
	
	private function align(width:Number,height:Number){
		trace("media.LecteurVideo.align(width"+width+", height"+height+")scaleMode"+scaleMode+" vAlign"+vAlign+" hAlign"+hAlign+" maxHeight"+maxHeight+" maxWidth"+maxWidth+"");
		switch (scaleMode) {
			case SCALLNONE:
			        maVideo._height=height;
                    maVideo._width=width;
			  
			break;
			case SCALLIN :
			 
			break;
			case SCALLOUT :
			break;
		}
		
		switch (vAlign) {
			case ALIGNCENTER :
				maVideo._y=yInit+(maxHeight-height)/2;
			break;
			case ALIGNTOP :
				maTrace("Pt.image.ImageLoader.redim(target_mc)+ALIGNTOP");
				maVideo._y=yInit;
			break;
			case ALIGNBOTTOM :
				maVideo._y=yInit+(maxHeight-height);
			break;
		}
		switch (hAlign) {
			case ALIGNCENTER :
				maVideo._x=xInit+(maxWidth-width)/2;
			break;
			case ALIGNLEFT :
				maVideo._x=xInit;
			break;
			case ALIGNRIGHT :
				maTrace("Pt.image.ImageLoader.redim(target_mc)+ALIGNRIGHT");
				maVideo._x=xInit+(maxWidth-width);
			break;
			
		}
		dispatchEvent(ON_RESIZE,new Event(this,ON_RESIZE));
	}
	
/** listenners */
private function initListener(){
		if (listenning) return;
				listenning=true;
				timer=new Temporise(100,Delegate.create(this,playUpdate),false);
				_ns.onStatus=Delegate.create(this,onStatus)
				_ns.onCuePoint=Delegate.create(this,onCuePoint)
				_ns.onMetaData=Delegate.create(this,onMetaData)
				_ns.onPlayStatus=Delegate.create(this,onPlayStatus)
	}
	
	private function onStatus (infoObject:Object) {
        maTrace("NetStream.onStatus called: ("+getTimer()+" ms)");
        for (var prop in infoObject) {
            maTrace("\t"+prop+":\t"+infoObject[prop]);
        }
        maTrace("");
        switch (infoObject.level) {
        	case "error":
        	   switch (infoObject.code) {
        	   	  case "NetStream.Play.StreamNotFound" :
        	   	    maTrace(infoObject.Error); 
        	   	    _root.err("ERREUR | video | "+Pt.Tools.Clips.convertURL(fichierFlux)+" | NetStream.Play.StreamNotFound");
        	   	    timer.destroy();
                  break;
                  case "NetStream.Seek.InvalidTime" :
                
                    maTrace(infoObject.Error.message.details); 
                     _root.err("ERREUR | video | "+Pt.Tools.Clips.convertURL(fichierFlux)+" | NetStream.Seek.InvalidTime " + infoObject.Error.message.details);
        	   	   
                  break;
                  default :
                  	    _root.err("ERREUR | video | "+Pt.Tools.Clips.convertURL(fichierFlux)+" | "+infoObject.code);
        	   	 
                  break;
                  
        	   }
        	break;
        	case "status":
        	   switch (infoObject.code) {
                 case "NetStream.Buffer.Empty" :
                    onBuffering();
                 break;
                 case "NetStream.Buffer.Full" :
                 break;
                 case "NetStream.Buffer.Flush" :
                 break;
                 case "NetStream.Play.Start" :
                    timer.reprise();
                    onPlaying();
                 break;
                 case "NetStream.Play.Stop" :
                   // timer.pause()
                    onStopped();
                 break;
                 case "NetStream.Seek.Notify" :
                    //onPaused();
                    onSeekingEnd();
                    //playheadUpdate();
                    SuspendedCall.createCall(playheadUpdate,this,1);
                 break;
                                                   
               }
        	break;
        }

    }
    private function onCuePoint (infoObject:Object) {
        maTrace("NetStream.onCuePoint called: ("+getTimer()+" ms)");
        for (var prop in infoObject) {
            maTrace("\t"+prop+":\t"+infoObject[prop]);
        }
        maTrace("");

    }
    private function onMetaData (infoObject:Object) {
        maTrace("NetStream.onMetaData called: ("+getTimer()+" ms)");
        for (var prop in infoObject) {
            maTrace("\t"+prop+":\t"+infoObject[prop]);
        }
        maTrace("");
        totalTime=Number(infoObject.duration);
        //maxWidth=Number(infoObject.width);
        //maxHeight=Number(infoObject.height);
        
        align(Number(infoObject.width),Number(infoObject.height));
        this.maVideo._visible=true;
        /*
        pp.hx:13: ->    canSeekToEnd:   true
App.hx:13: ->   audiocodecid:   2
App.hx:13: ->   audiodelay: 0.038
App.hx:13: ->   audiodatarate:  96
App.hx:13: ->   videocodecid:   4
App.hx:13: ->   framerate:  25
App.hx:13: ->   videodatarate:  400
App.hx:13: ->   height: 288
App.hx:13: ->   width:  360
App.hx:13: ->   duration:   83.38
            */
            dispatchEvent(ON_INFO,new Event(this,ON_INFO,[infoObject]));

    }
    private function onPlayStatus (infoObject:Object) {
        maTrace("NetStream.onPlayStatus called: ("+getTimer()+" ms)");
        for (var prop in infoObject) {
            maTrace("\t"+prop+":\t"+infoObject[prop]);
        }
        maTrace("");

    }


	/** interface avec barres de lecture */
	public function onPlayPress(){
		
		this.play()	;
	}
	public function onPausePress(){
		
		this.pause()	;
	}
	public function onStopPress(){
		
		this.stop()	;
	}
	public function onGotoPress(src:Object,pc:Number){
		
		this.setGotoTo(pc);
	}
	
}