class java7::params {
  $java7_version = $::hostname ? {
      default => "1.7.0_25",
  }
  $java7_base = $::hostname ? {
      default => "/opt/java7",
  }
}
