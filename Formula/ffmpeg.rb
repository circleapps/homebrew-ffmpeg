class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.1.1.tar.xz"
  version "4.1.1-with-options" # to distinguish from homebrew-core's ffmpeg
  sha256 "373749824dfd334d84e55dff406729edfd1606575ee44dd485d97d45ea4d2d86"
  head "https://github.com/FFmpeg/FFmpeg.git"

  # This formula is for people that will compile with their chosen options
  bottle :unneeded
  
  option "with-frei0r", "Enable frei0r library"
  option "with-subtitle", "Enable subtitle support"
  option "with-gpl", "Enable GPL code"
  option "with-libass", "Enable libass library"
  option "with-tesseract", "Enable the tesseract OCR engine"
  option "with-libvidstab", "Enable vid.stab support for video stabilization"
  option "with-openh264", "Enable OpenH264 library"
  option "with-x264", "Enable x264 library"
  option "with-x265", "Enable x265 library"
  option "with-openjpeg", "Enable JPEG 2000 image format"
  option "with-rubberband", "Enable rubberband library"
  option "with-rtmp", "Enable rtmp"
  option "with-disable-securetransport", "Disable Secure Transport"

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "texi2html" => :build

  depends_on "aom"
  depends_on "lame"
  depends_on "libsoxr"
  depends_on "libvorbis"
  depends_on "libvpx"
  #depends_on "opencore-amr"
  depends_on "opus"
  #depends_on "sdl2"
  depends_on "snappy"
  depends_on "speex"
  depends_on "theora"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"

  unless OS.mac?
    depends_on "zlib"
    depends_on "bzip2"
    depends_on "linuxbrew/xorg/libxv"
  end
  
  depends_on "frei0r" => :optional
  depends_on "libass" => :optional
  depends_on "libcaca" => :optional
  depends_on "libgsm" => :optional
  depends_on "libmodplug" => :optional
  depends_on "librsvg" => :optional
  depends_on "libvidstab" => :optional
  depends_on "openh264" => :optional
  depends_on "openjpeg" => :optional
  depends_on "rtmpdump" => :optional
  depends_on "rubberband" => :optional
  depends_on "tesseract" => :optional
  depends_on "two-lame" => :optional
  depends_on "wavpack" => :optional
  depends_on "webp" => :optional
  depends_on "sdl2" => :optional
  #depends_on "fontconfig" => :optional
  #depends_on "freetype" => :optional
 
  #--enable-libopencore-amrnb
  #--enable-libopencore-amrwb

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-hardcoded-tables
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-version3
      --enable-libaom
      --enable-libmp3lame
      --enable-libopus
      --enable-libsnappy
      --enable-libtheora
      --enable-libvorbis
      --enable-libvpx
      --enable-libxvid
      --enable-libspeex
      --enable-libsoxr
      --disable-sdl2
      --disable-libjack
      --disable-indev=jack
      --disable-filters
      --enable-filter=delogo
    ]

    if OS.mac?
      args << "--enable-opencl"
      args << "--enable-videotoolbox"
    end

    args << "--disable-htmlpages" # doubtful anyone will look at this. The same info is accessible through the man pages.
    args << "--enable-gpl" if build.with? "gpl"
    args << "--enable-libass" if build.with? "libass"
    args << "--enable-libcaca" if build.with? "libcaca"
    args << "--enable-libfdk-aac" if build.with? "fdk-aac"
    args << "--enable-libgsm" if build.with? "libgsm"
    args << "--enable-libmodplug" if build.with? "libmodplug"
    args << "--enable-libopenh264" if build.with? "openh264"
    args << "--enable-librsvg" if build.with? "librsvg"
    args << "--enable-librtmp" if build.with? "rtmp"
    args << "--enable-librubberband" if build.with? "rubberband"
    args << "--enable-libsoxr" if build.with? "libsoxr"
    args << "--enable-libtesseract" if build.with? "tesseract"
    args << "--enable-libtwolame" if build.with? "two-lame"
    args << "--enable-libvidstab" if build.with? "libvidstab"
    args << "--enable-libwavpack" if build.with? "wavpack"
    args << "--enable-frei0r" if build.with? "frei0r"
    args << "--enable-libx264" if build.with? "x264"
    args << "--enable-libfontconfig" if build.with? "subtitle"
    args << "--enable-libfreetype" if build.with? "subtitle"
    args << "--disable-securetransport" if build.with? "disable-securetransport"

    if build.with? "openjpeg"
      args << "--enable-libopenjpeg"
      args << "--disable-decoder=jpeg2000"
      args << "--extra-cflags=" + `pkg-config --cflags libopenjp2`.chomp
    end

    # These librares are GPL-incompatible, and require ffmpeg be built with
    # the "--enable-nonfree" flag, which produces unredistributable libraries
    args << "--enable-nonfree" if build.with?("fdk-aac") || build.with?("openssl")

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
