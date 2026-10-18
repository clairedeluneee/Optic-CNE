package epoch;

class Strain {
    public static function getStrainOfStrumline(strumline:Dynamic):Dynamic {
        var toReturn:Dynamic = {average: 0, laneStrains: []}

        var individualStrains:Array<Float> = [];
        var lastNote:Array<Dynamic> = [];
        for (i in 0...(strumline?.keyCount ?? 4)) {
            individualStrains.push(0);
            lastNote.push(null);
        }

        for (note in strumline.notes) {
            if (lastNote[note.id] == null) {
                lastNote[note.id] = note;
                continue;
            }

            individualStrains[note.id] += (1 / Math.abs(0.001 * (note.time - (lastNote[note.id].time + lastNote[note.id].slen))));
        }

        toReturn.laneStrains = individualStrains;
        for (i in individualStrains) toReturn.average += i;
        toReturn.average /= individualStrains.length;

        return toReturn;
    }
}
