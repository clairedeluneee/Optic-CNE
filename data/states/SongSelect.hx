import optic.Parser;
import epoch.Strain;

import funkin.backend.system.Controls;

import funkin.game.StrumLine;
import funkin.game.Strum;
import funkin.game.PlayState;

import lime.app.Promise;

import Utils;

var scannables:Array<String> = [];
var chartData:Array<Dynamic> = [];
var folderMap:Map<String, String> = [];

var loader;

var currentSelection = 0;

var selCam = Utils.makeCamera(true);
var uiCam = Utils.makeCamera(true);

var preview;
var titleCache = "";

var background;
var indicatorBump = Utils.makeRect(0, 0, 1, 32, 0xffffffff, false);

function create() {
    background = new FlxSprite();
    background.alpha = 0.5;
    add(background);
    loader = loadAll();

    loader.onComplete( function(d) { makeAll(d); chartData = d; });
    loader.onProgress( function(p, t) { trace("Loaded: " + p + "/" + t); });

    changeSel(0);

    add(indicatorBump);
    indicatorBump.origin.x = 0;
    indicatorBump.y = FlxG.height / 2 - indicatorBump.height / 2;
}

function update() {
    if (FlxG.keys.justPressed.DOWN) changeSel(1);
    if (FlxG.keys.justPressed.UP) changeSel(-1);

    selCam.scroll.y = CoolUtil.fpsLerp(selCam.scroll.y, currentSelection * 48 - FlxG.height / 2 + 32, 0.5);

    indicatorBump.scale.x = 12 - 8 * FlxEase.circOut(Conductor.curBeatFloat - Conductor.curBeat);
}


function changeSel(delta) {
    currentSelection += delta;

    if (currentSelection < 0) currentSelection = chartData.length - 1;
    if (currentSelection > chartData.length - 1) currentSelection = 0;

    CoolUtil.playMenuSFX();
    PlayState.SONG = chartData[currentSelection];
    var folderPath = "maps/" + folderMap[PlayState.SONG.meta.customValues["BeatmapSetID"]] + "/";

    background.loadGraphic(Paths.file(folderPath + PlayState.SONG.meta.customValues["BackgroundImage"]));

    var scale = Math.min(FlxG.width / background.width, FlxG.height / background.height);
    background.scale.set(scale, scale);

    background.x = FlxG.width / 2 - background.width / 2;
    background.y = FlxG.height / 2 - background.height / 2;

    if (titleCache != PlayState.SONG.meta.name) {
        titleCache = PlayState.SONG.meta.name;
        var path = Paths.file(
            folderPath + PlayState.SONG.meta.customValues["AudioFilename"]
        );

        CoolUtil.playMusic(
            path,
            true,
            1,
            true,
            PlayState.SONG.meta.customValues["TimingPoints"][0].params[0]
        );


        FlxG.sound.music.pause();
        FlxG.sound.music.time = Std.parseFloat(PlayState.SONG.meta.customValues["PreviewTime"]);
        FlxG.sound.music.play();

        Conductor.songOffset = PlayState.SONG.meta.customValues["TimingPoints"][0].time;
        Conductor.songPosition = FlxG.sound.music.time;
    }
}

var index = 0;
function makeAll(chartd) {
    for (d in chartd) {
        var targ = 16 + 48 * index;

        var strain = Utils.makeText(16, targ - 2, Math.floor(Strain.getStrainOfStrumline(d.strumLines[0]).average), 32);

        var title = Utils.makeText(16 + 48, targ, d.meta.name, 16);
        var artist = Utils.makeText(16 + 48, targ + 16, d.meta.customValues["Artist"] + " - " + d.meta.difficulties[0], 12);

        for (m in [strain, title, artist]) {
            m.camera = selCam;
            add(m);
        }

        index++;
    }
}

function loadAll() {
    var promise = new Promise<Dynamic>();
    var cd = [];

    scannables = Paths.getFolderDirectories("maps");

    var toParse = [];
    var folders = [];
    for (i in scannables) {
        for (j in Paths.getFolderContent("maps/" + i)) {
            if (j.indexOf(".osu") != -1) {
                toParse.push("maps/"+i+"/"+j);
                folders.push(i);
            }
        }
    }

    var done = 0;
    for (m in toParse) {
        cd.push(Parser.parseFromText(Assets.getText(Paths.file(m))));
        done++;
        promise.progress(done, toParse.length);
        folderMap.set(cd[done-1].meta.customValues["BeatmapSetID"], folders[done-1]);
        cd[done-1].meta.customValues.set("FolderLocation", folders[done-1]);
    }
    promise.complete(cd);

    return promise.future;
}
