#!/bin/bash
set -ue -o pipefail
export LC_ALL=C

# oci.greedy.instancation.sh
# https://github.com/furplag/archive/OCI
# 
# Licensed under CC0 1.0 (https://creativecommons.org/publicdomain/zero/1.0/deed)
#
# do trying until create compute instance into your OCI tenant .
# maybe useful for poor man like me, but currently just only for me own .
#
# Requirement
# - [ ] [oci-cli](https://github.com/oracle/oci-cli/) and complete setup to use that .
# - [ ] a VM instance need to could be accessible to internet .
# - [ ] all commands need you are "root" or you listed in "wheel"
#

# variable
if ! declare -p name >/dev/null 2>&1; then declare -r name=`basename ${0:-}`; fi
if ! declare -p basedir >/dev/null 2>&1; then declare -r basedir=$(cd $(dirname $0); pwd); fi

# variable ( required )
if ! declare -p compartment_id >/dev/null 2>&1; then declare -r compartment-id=; fi
if ! declare -p availability_domain >/dev/null 2>&1; then declare -r availability_domain=; fi
if ! declare -p subnet_id >/dev/null 2>&1; then declare -r subnet_id=; fi
if ! declare -p image_id >/dev/null 2>&1; then declare image_id=; fi
if ! declare -p display_name >/dev/null 2>&1; then declare display_name=\; fi

if ! declare -p ssh_authorized_keys_file >/dev/null 2>&1; then declare ssh_authorized_keys_file=; fi

# variable ( optional )
if ! declare -p shape >/dev/null 2>&1; then declare shape='VM.Standard.A1.Flex'; fi
if ! declare -p private_ip >/dev/null 2>&1; then declare private_ip='10.0.0.101'; fi
if ! declare -p availability_config >/dev/null 2>&1; then declare availability_config='{"recoveryAction": "RESTORE_INSTANCE"}'; fi
if ! declare -p instance_options >/dev/null 2>&1; then declare instance_options='{"areLegacyImdsEndpointsDisabled": false}'; fi
if ! declare -p shape_config >/dev/null 2>&1; then
  declare shape_config="$(if [[ "${shape}" = 'VM.Standard.A1.Flex' ]]; then echo '{"baselineOcpuUtilization":"BASELINE_1_1","memoryInGbs":24,"ocpus":4}'; else echo ''; fi)";
fi

# variable ( flag: true if specified and the value is 0 )
if ! declare -p assign_public_ip >/dev/null 2>&1; then declare -i assign_public_ip=1; fi
if ! declare -p not_assign_private_dns_record >/dev/null 2>&1; then declare -i not_assign_private_dns_record=1; fi

# [WIP]
echo "name=[${name}]";
echo "basedir=[${basedir}]";

# variable ( required )
echo "compartment_id=[${compartment_id}]";
echo "availability_domain=[${availability_domain}]";
echo "subnet_id=[${subnet_id}]";
echo "image_id=[${image_id}]";
echo "display_name=[${display_name}]";

echo "ssh_authorized_keys_file=[${ssh_authorized_keys_file}]";

# variable ( optional )
echo "shape=[${shape}]";
echo "private_ip=[${private_ip}]";
echo "availability_config=[${availability_config}]";
echo "instance_options=[${instance_options}]";
echo "shape_config=[${shape_config}]";

# variable ( flag: true if specified and the value is 0 )
echo "assign_public_ip=[${assign_public_ip}]";
echo "not_assign_private_dns_record=[${not_assign_private_dns_record}]";

cat <<_EOT_
oci compute instance launch \
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
 --shape_config "${shape_config}" \
 --ssh-authorized-keys-file "${ssh_authorized_keys_file}";
_EOT_
;
