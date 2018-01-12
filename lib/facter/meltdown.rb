require 'json'

def json_stub
  value = <<-EOT
  [
    {
      "NAME": "SPECTRE VARIANT 1",
      "CVE": "CVE-2017-5753",
      "VULNERABLE": false,
      "INFOS": "106 opcodes found, which is >= 70, heuristic to be improved when official patches become available"
    },
    {
      "NAME": "SPECTRE VARIANT 2",
      "CVE": "CVE-2017-5715",
      "VULNERABLE": true,
      "INFOS": "IBRS hardware + kernel support OR kernel with retpoline are needed to mitigate the vulnerability"
    },
    {
      "NAME": "MELTDOWN",
      "CVE": "CVE-2017-5754",
      "VULNERABLE": false,
      "INFOS": "PTI mitigates the vulnerability"
    }
  ]
  EOT
  value
end

Facter.add('meltdown') do
  # confine :kernel => :linux
  value = ''
  checker_script = ''
  setcode do
    if Facter.value(:osfamily) == 'Darwin'
      # just generate some output for testing
      value = JSON.parse(json_stub)
    else
      # get the script path relative to facter Ruby program
      checker_script = File.join(File.expand_path(File.dirname(__FILE__)), '..',
                                 'meltdown', 'spectre-meltdown-checker.sh')
      value = JSON.parse(Facter::Core::Execution.exec("/bin/sh #{checker_script} --batch json"))
    end
    JSON.pretty_generate(value)
  end
end

# generate CVE-specific facts
meltdown_hash = JSON.parse(Facter.value('meltdown'))

meltdown_hash.each do |item|
  # puts item["CVE"].downcase
  # puts item["VULNERABLE"]
  Facter.add(item['CVE'].downcase) do
    setcode do
      item['VULNERABLE']
    end
  end
end
