package optic;

using StringTools;

/**
* The class that converts osu files to CNE readable jsons. I'm out of names, bruv.
*/
class Parser {

	public static function parseFromText(text:String):Dynamic {


        var notes:Array<Dynamic> = [];

		var meta:Map<String, String> = [];
		var timingPoints:Array<Dynamic> = [];
		var storyboardElements:Array<Dynamic> = []; // this is just to facilitate the background, i aint implementing storyboarding but it is there for future me to pick up
		var breaks:Array<Dynamic> = [];
		var curSection:String = "";

		var iniSections:Array<String> = ["[General]", "[Editor]", "[Metadata]", "[Difficulty]", "[Colours]"];

		for (line in text.split("\r\n")) {
		    if (line.charAt(0) == "[") {
				curSection = line;
				continue;
			}

			// if check passes, add to meta
			if (iniSections.contains(curSection)) {
			    meta.set(line.substr(0, line.indexOf(":")).trim(), line.substr(line.indexOf(":") + 1).trim());
				continue;
			}

			switch (curSection) {
			    case "[HitObjects]":
					// now we can do some bullshit
					// hold syntax: x,y,time,type,hitSound,endTime:hitSample
					var split:Array<String> = line.split(",");
					if (split[5] == null) break;
					var endtime = split[5].substr(0, split[5].indexOf(":")-1);
					notes.push({
					    time: Std.parseFloat(split[2]),
						id: Math.floor(Std.parseFloat(split[0]) / 512 * 4),
						type: 0,
						sLen: Std.parseFloat(split[2]) - endtime
					});

				case "[TimingPoints]":
				    // timing point syntax: time,beatLength,meter,sampleSet,sampleIndex,volume,uninherited,effects
				    var split:Array<String> = line.split(",");

						// if check passes, then the timing point is an uninherited one
						// and we need to change tempo
						//
						// as of right now we dont need to worry about inherited ones since there wont be any
						// sv functionality
					if (split[6] == "1") {
					    timingPoints.push
						({
							time: Std.parseFloat(split[0]),
							name: "BPM Change",
							params: [ 1 / Std.parseFloat(split[1]) * 60 * 1000],
							global: true
						});
					}

				case "[Events]":
				    var split:Array<String> = line.split(",");
					if (split[0].trim() == "0" && split[1].trim() == "0") {
					    meta.set("BackgroundImage", split[2].trim().replace("\"", ""));
					    continue;
					}

			    default:
					// do jackshit
			}

		}

		meta.set("FolderPath", meta["BeatmapSetID"] + " " + meta["Title"]);
		meta.set("TimingPoints", timingPoints);

        var theOneStrumline:Dynamic =
      		{
      		    type: 1,
     			position: "bf",
     			notes: notes,
      		    characters: ["bf"]
      		};

        var output:Dynamic =
            {
                strumLines: [theOneStrumline],
            	stage: "stage",
            	scrollSpeed: 3.2,
            	noteTypes: [],
            	meta:
                    {
                        name: meta["Title"],
                        bpm: timingPoints[0].params[0],
                        customValues: meta,
                        difficulties: [meta["Version"]]
                    },
            	events: timingPoints,
            	codenameChart: false,
            };

		return output;
	}
}
