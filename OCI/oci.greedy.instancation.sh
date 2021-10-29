#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

# oci.greedy.instancation.sh
# https://github.com/furplag/archive/OCI
#
# Licensed under CC-BY-NC-SA 4.0 ( https://creativecommons.org/licenses/by-nc-sa/4.0/ )
#
# do trying until create compute instance into your OCI tenant .
# maybe useful for poor man like me, but currently just only for me own .
#
# Requirement
# - [ ] [oci-cli](https://github.com/oracle/oci-cli/) and complete setup to use that .
# - [ ] a VM instance need to could be accessible to internet .
#

# variable
if ! declare -p name >/dev/null 2>&1; then declare -r name="$(_name=`basename ${0:-}`; if [[ "${_name}" = 'bash' ]]; then echo 'oci.greedy.instancation.sh'; else echo "${_name}"; fi)"; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir="$(_basedir="$(cd $(dirname $0); pwd)"; if [[ "${_basedir}" = '/bin' ]]; then echo "$(cd ~/; pwd)"; else echo "${_basedir}"; fi)"; fi
if ! declare -p result >/dev/null 2>&1; then declare -r result="${basedir}/${name}.done"; fi

if [[ -f "${result}" ]]; then exit 0; fi

# variable ( required )
if ! declare -p compartment_id >/dev/null 2>&1; then declare -r compartment_id=; fi
if ! declare -p availability_domain >/dev/null 2>&1; then declare -r availability_domain=; fi
if ! declare -p subnet_id >/dev/null 2>&1; then declare -r subnet_id=; fi
if ! declare -p image_id >/dev/null 2>&1; then declare image_id=; fi
if ! declare -p display_name >/dev/null 2>&1; then declare display_name=; fi

for _required in compartment_id availability_domain subnet_id image_id display_name; do
  if [[ "$(echo "\$\{$_required\}")" = '' ]]; then exit 1; fi
done

if ! declare -p ssh_authorized_keys_file >/dev/null 2>&1; then declare ssh_authorized_keys_file=; fi
if [[ ! -f "${ssh_authorized_keys_file}" ]]; then exit 1; fi

# variable ( optional )
if ! declare -p shape >/dev/null 2>&1; then declare shape='VM.Standard.A1.Flex'; fi
if ! declare -p private_ip >/dev/null 2>&1; then declare private_ip='10.0.0.101'; fi
if ! declare -p availability_config >/dev/null 2>&1; then declare availability_config='{"recoveryAction": "RESTORE_INSTANCE"}'; fi
if ! declare -p instance_options >/dev/null 2>&1; then declare instance_options='{"areLegacyImdsEndpointsDisabled": false}'; fi
if ! declare -p memory_in_gbs >/dev/null 2>&1; then declare memory_in_gbs=24; fi
if ! declare -p ocpus >/dev/null 2>&1; then declare ocpus=4; fi
if ! declare -p shape_config >/dev/null 2>&1; then
  declare shape_config="$(if [[ "${shape}" = 'VM.Standard.A1.Flex' ]]; then echo "{\"baselineOcpuUtilization\":\"BASELINE_1_1\",\"memoryInGbs\":${memory_in_gbs},\"ocpus\":${ocpus}}"; else echo ''; fi)";
fi

# variable ( flag: true if specified and the value is 0 )
if ! declare -p assign_public_ip >/dev/null 2>&1; then declare -i assign_public_ip=1; fi
if ! declare -p not_assign_private_dns_record >/dev/null 2>&1; then declare -i not_assign_private_dns_record=1; fi

if [[ -f "${result}" ]]; then exit 0;
else _result="$(oci compute instance launch \
  --compartment-id "${compartment_id}" \
  --availability-domain "${availability_domain}" \
  --shape "${shape}" \
  --image-id "${image_id}" \
  --subnet-id "${subnet_id}" \
  --display-name "${display_name}" \
  --private-ip "${private_ip}" \
  --assign-public-ip $(if [[ "${assign_public_ip:-1}" = '0' ]]; then echo 'true'; else echo 'false'; fi) \
  --assign-private-dns-record $(if [[ "${not_assign_private_dns_record:-1}" = '0' ]]; then echo 'false'; else echo 'true'; fi) \
  --availability-config "${availability_config}" \
  --instance-options "${instance_options}" \
  --shape-config "${shape_config}" \
  --ssh-authorized-keys-file "${ssh_authorized_keys_file}"
)"
  if [[ "${?:-1}" = "0" ]]; then echo "${_result}" >"${result}"; fi
fi