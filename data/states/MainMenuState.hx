function update() {
    if (FlxG.keys.justPressed.O) {
        FlxG.switchState(new ModState("SongSelect"));
    }
}
