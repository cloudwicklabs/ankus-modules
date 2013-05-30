require 'facter'
Facter.add("kadm_keytab") do
  setcode do
     %x{[ -f /etc/kadm5.keytab ] && base64 </etc/kadm5.keytab 2>/dev/null} + "\n"
  end
end