class Utils {
    public static function makeText(x:Float, y:Float, str:String, size:Float, align:String = "left", outline:Bool = true):FunkinText {
		var t = new FunkinText(x, y, 0, str, size, outline);
		t.antialiasing = Options.antialiasing;
		t.alignment = align;
		return t;
	}
	public static function makeCamera(autoAdd:Bool = false):HudCamera {
		cam = new HudCamera();
		cam.bgColor = 0x00000000;
		if (autoAdd)
			FlxG.cameras.add(cam, false);
		return cam;
	}
}
