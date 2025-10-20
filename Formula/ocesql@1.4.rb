class OcesqlAT14 < Formula
  desc "Open COBOL ESQL — preprocessor and runtime support for Embedded SQL in OpenCOBOL/GnuCOBOL"
  homepage "https://github.com/opensourcecobol/Open-COBOL-ESQL"

  # Stable: point explicitly at the v1.4 release tarball
  url "https://github.com/opensourcecobol/Open-COBOL-ESQL/archive/refs/tags/v1.4.tar.gz"
  version "1.4"
  sha256 "c0310473aa38ea2921ae4c45ff2463be9cd874efd488d23cd8b0f687644060fd"
  license "GPL-3.0-or-later"

  # Build toolchain (autotools-based project)
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext" => :build
  depends_on "python@3.11" => :build

  # Use the libpq client library (provides libpq-fe.h). Make it a hard dependency
  # so the configure-time check can always find headers/libraries.
  depends_on "libpq"

  # Database client helper: unixODBC for ODBC support (optional/recommended)
  depends_on "unixodbc" => :recommended

  def install
    # Ensure libpq is discoverable for configure:
    libpq = Formula["libpq"]
    ENV.prepend_path "PKG_CONFIG_PATH", libpq.opt_lib/"pkgconfig"
    ENV.prepend_path "PATH", libpq.opt_bin
    ENV.append "CPPFLAGS", "-I#{libpq.opt_include}"
    ENV.append "LDFLAGS", "-L#{libpq.opt_lib}"
    # Some configure checks accept LIBPQ_CFLAGS / LIBPQ_LIBS
    ENV["LIBPQ_CFLAGS"] = "-I#{libpq.opt_include}"
    ENV["LIBPQ_LIBS"]   = "-L#{libpq.opt_lib} -lpq"

    # If autogen.sh is present (git source), bootstrap; release tarballs usually contain configure.
    system "./autogen.sh" if File.exist?("autogen.sh")

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"

    prefix.install_metafiles
  end

  test do
    out = shell_output("#{bin}/ocesql -V 2>&1", 0)
    assert_match(/version|usage|-V/i, out)
  end
end
