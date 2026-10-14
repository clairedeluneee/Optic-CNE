package optic;

/**
* The class that converts osu files to CNE readable jsons. I'm out of names, bruv.
*/
class Parser {

	public function parseFromText(text:String):Dynamic {
	    var theOneStrumline:Dynamic =
    		{
    		    type: 1,
    			position: "bf",
    			notes: [],
    		    characters: ["bf"]
    		};

		var meta:Map<String, String> = [];
		var timingPoints:Array<Dynamic> = [];
		var curSection:String = "";

		var iniSections:Array<String> = ["[General]", "[Editor]", "[Metadata]", "[Difficulty]", "[Colours]"];

		for (line in text.split("\n")) {
		    if (line.charAt(0) == "[") {
				curSection = line;
				continue;
			}

			// if check passes, add to meta
			if (iniSections.contains(curSection)) {
			    meta.set(line.substr(0, line.indexOf(":") - 1), line.substr(line.indexOf(":") + 1));
				continue;
			}

			switch (curSection) {
			    case "[HitSection]":
					// now we can do some bullshit
					// hold syntax: x,y,time,type,hitSound,endTime:hitSample
					var split:Array<String> = line.split(",");
					split[5] = split[5].substr(0, split[5].indexOf(":")-1);

					theOneStrumline.notes.push({
					    time: Std.parseFloat(split[2]),
						id: Math.floor(Std.parseFloat(split[0]) / 512 * 4),
						type: 0,
						sLen: Std.parseFloat(split[2]) - Std.parseFloat(split[5])
					});

				case "[TimingPoints]":
				    // timing point syntax: time,beatLength,meter,sampleSet,sampleIndex,volume,uninherited,effects
				    var split:Array<String> = line.split(",");

						// if check passes, then the timing point is an uninherited one
						// and we need to change tempo
						//
						// as of right now we dont need to worry about inherited ones since there wont be any
						// sv functionality
					if (split[6] != "1") {
					    timingPoints.push
						({
							time: Std.parseFloat(split[0]),
							name: "BPM Change",
							params: [ 1 / Std.parseFloat(split[1]) * 60],
							global: true
						});
					}

			    default:
					// do jackshit
			}

		}

		var theMeta:Dynamic =
            {
                name: meta.get("TitleUnicode"),
                bpm: 0,
                customValues: meta,
                difficulties: [meta.get("Version")]
            }

        var output:Dynamic =
        {
            strumLines: [theOneStrumline],
        	stage: "stage",
        	scrollSpeed: 3.2,
        	noteTypes: [],
        	meta: theMeta,
        	events: timingPoints,
        	codenameChart: false,
        };

		return output;
	}
}
