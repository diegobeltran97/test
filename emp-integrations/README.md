# Denmark Support - Integrated Environment

This `docker-compose` creates an environment for Denmark project with both: EMP and Integrations services images integrated.

## How to run

1. Clone repository

        git clone ssh://git@git.smartmatic.net:32323/engineering_server_side_content/dnk-support.git
        cd dnk-support

1. Add the container names (**empapp-dnk** and **intapp-dnk**) to your `/etc/hosts` file to resolve to `127.0.0.1`

        127.0.0.1	localhost empapp-dnk intapp-dnk
        ...

1. Pull the docker images to use

        ./docker-controller.sh --pull

1. Start the environment

        ./docker-controller.sh --up

1. [Optional] Load test user roles to the database. Execute the following after the EMP is up & running

        ./docker-controller.sh --run-sql 01-user-role.sql

1. [Optional] Loggin to EMP and run **bulk dataimport** once ended, run the following to associate Election Boards to user roles

        ./docker-controller.sh --run-sql 02-user-role.sql

## How to use specific versions of EMP or Integrations

1. Edit the `docker-controller.sh` file and change following lines according to the desired versions

        export EMP_VERSION=snapshot
        ...
        export INT_VERSION=2.5.2.2

1. Re-create the environment

        ./docker-controller.sh --up

## How to stop

1. Run the following

        ./docker-controller.sh --down

## How to update images

1. If a new version of *Integrations Team* is released, pull those images using the following [Jenkins Job][1].

1. Pull services images

        ./docker-controller.sh --pull

## How to execute SQL scripts inside Oracle DB container

The database container is launched with a volume mapped to `sql` directory, so all the scripts present in that directory can be run inside the container using the following command

    ./docker-controller.sh --run-sql <file_name.sql>

[1]: http://jenkins.smartmatic.net/view/Denmark/job/INTEGRATIONS_DOCKER_PULL/
