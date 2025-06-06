# /etc/profile.d/java.sh

# Set Environment with alternatives for Java VM.
export JAVA_HOME=$(readlink /etc/alternatives/java | sed -e 's/\/bin\/java//g')
