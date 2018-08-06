s.scope





(

Routine.run{

  ~binauralDecoder = FoaDecoderKernel.newCIPIC;
  ~micAngle = (131/2).degrad; // at 131 deg
  ~micPattern = 0.5; // Cardioids
  // ~binauralDecoder = FoaDecoderMatrix.newStereo(~micAngle, ~micPattern);
  ~converterMatrix = FoaEncoderMatrix.newHoa1(\acn, \sn3d);


s.sync;

~decoder = {|monitorAz1 = 0, monitorElev1 = 0, monitorAz2 = 0, monitorElev2 = 0|
		           var sig, bFormatSN3D, adjust, rotatedFieldMonitor1, rotatedFieldMonitor2, binauralMonitor1, binauralMonitor2 ;
		           sig = In.ar(11,4) ;
				   adjust   = FoaRotate.ar(sig, -0.5pi) ;
				   // bFormatSN3D = HOAConverterFuma2AcnSn3d.ar( 1, adjust ) ;
	               bFormatSN3D = FoaEncode.ar(adjust, ~converterMatrix);
				   rotatedFieldMonitor1 =  FoaRotate.ar( adjust, monitorAz1 ) ;
				   rotatedFieldMonitor2 =  FoaRotate.ar( adjust, monitorAz2     ) ;
				   binauralMonitor1     =  FoaDecode.ar( rotatedFieldMonitor1 , ~binauralDecoder)   ;
				   binauralMonitor2     =  FoaDecode.ar( rotatedFieldMonitor2 ,  ~binauralDecoder ) ;
				   Out.ar(0,[binauralMonitor1, binauralMonitor2, bFormatSN3D,  SoundIn.ar( [0,1]) ].flatten );
				   // Out.ar(0,[SoundIn.ar( [0,1]), bFormatSN3D, binauralMonitor1].flatten );
			       }.play;


s.sync;


~sources = [];


64.do({~sources.add(

	{|az = 0.0, elev = 0, gain = 0.1, i_out= 11, i_inBus = 0|
      var pannedSig, in;
      in = In.ar(20, 1);
      // pannedSig = HOAEncoder.ar(1, in , az, elev, 0, 0);
		pannedSig = FoaPanB.ar(in , MouseX.kr(-pi, pi) , elev);
	  // pannedSig = FoaEncode.ar(in, FoaEncoderMatrix.newDirection(az,elev) );
	  Out.ar(i_out, pannedSig * gain)
     }.play;

s.sync;


) } );



{ Out.ar(20, /* WhiteNoise.ar(0.1) */  SinOsc.ar(440, 0, 1) );}.play

}

)
