# Echo DApp

This example shows how to build and interact with a minimalistic Cartesi Rollups application that simply copies (or "echoes") each input received as a corresponding output notice. This DApp's back-end is written in Python.

## Building the environment

To run the echo example, clone the repository as follows:

```shell
$ git clone https://github.com/cartesi/rollups-examples.git
```

Then, build the back-end for the echo example:

```shell
$ cd rollups-examples/echo
$ make machine
```

## Running the environment

In order to start the containers in production mode, simply run:

```shell
$ docker-compose up --build
```

_Note:_ If you decide to use [Docker Compose V2](https://docs.docker.com/compose/cli-command/), make sure you set the [compatibility flag](https://docs.docker.com/compose/cli-command-compatibility/) when executing the command (e.g., `docker compose --compatibility up`).

Allow some time for the infrastructure to be ready.
How much will depend on your system, but after some time showing the error `"concurrent call in session"`, eventually the container logs will repeatedly show the following:

```shell
server_manager_1      | Received GetVersion
server_manager_1      | Received GetStatus
server_manager_1      |   default_rollups_id
server_manager_1      | Received GetSessionStatus for session default_rollups_id
server_manager_1      |   0
server_manager_1      | Received GetEpochStatus for session default_rollups_id epoch 0
```

To stop the containers, first end the process with `Ctrl + C`.
Then, remove the containers and associated volumes by executing:

```shell
$ docker-compose down -v
```

## Interacting with the application

With the infrastructure in place, you can interact with the application using a set of Hardhat tasks. 

First, go to a separate terminal window, switch to the `echo/contracts` directory, and run `yarn`:

```shell
$ cd echo/contracts/
$ yarn
```

Then, send an input as follows:

```shell
$ npx hardhat --network localhost echo:addInput --input "0x63617274657369"
```

The input will have been accepted when you receive a response similar to the following one:

```shell
Added input '0x63617274657369' to epoch '0' (index '0', timestamp: 1640643170, signer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, tx: 0x31d7e9e810d8702196623837b8512097786b544a4b5ffb52f693b9ff7d424147)
```

In order to verify the notices generated by your inputs, run the command:

```shell
$ npx hardhat --network localhost echo:getNotices --epoch 0 
```

The response should be something like this:

```shell
{"session_id":"default_rollups_id","epoch_index":"0","input_index":"0","notice_index":"0","payload":"63617274657369"}
```

You can also send inputs as regular strings. For example:

```shell
$ npx hardhat --network localhost echo:addInput --input 'Hello there!'
```

To retrieve notices interpreting the payload as a UTF-8 string, you can use the `--payload string` option:

```shell
$ npx hardhat --network localhost echo:getNotices --epoch 0 --payload string
{"session_id":"default_rollups_id","epoch_index":"0","input_index":"1","notice_index":"0","payload":"cartesi"}
```

Finally, note that you can check the available options for all Hardhat tasks using the `--help` switch:

```shell
$ npx hardhat --help
```

## Advancing time

To advance time, in order to simulate the passing of epochs, run:

```shell
$ npx hardhat --network localhost util:advanceTime --seconds 864010
```

## Running the environment in host mode

When developing an application, it is often important to easily test and debug it. For that matter, it is possible to run the Cartesi Rollups environment in [host mode](../README.md#host-mode), so that the DApp's back-end can be executed directly on the host machine, allowing it to be debugged using regular development tools such as an IDE.

The first step is to run the environment in host mode using the following command:

```shell
$ docker-compose -f docker-compose.yml -f docker-compose-host.yml up --build
```

The next step is to run the echo server in your machine. The application is written in Python, so you need to have `python3` installed.

In order to start the echo server, run the following commands in a dedicated terminal:

```shell
$ cd echo/server/
$ python3 -m venv .env
$ . .env/bin/activate
$ pip install -r requirements.txt
$ ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004" python3 echo.py
```

This will run the echo server and send the corresponding notices to port `5004`.

The final command, which effectively starts the server, can also be configured in an IDE to allow interactive debugging using features like breakpoints.
You can also use a tool like [entr](https://eradman.com/entrproject/) to restart it automatically when the code changes. For example:

```shell
$ ls *.py | ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004" entr -r python3 echo.py
```

After the server successfully starts, it should print an output like the following:

```
INFO:__main__:HTTP rollup_server url is http://127.0.0.1:5004
INFO:__main__:Sending finish
```

After that, you can interact with the application normally [as explained above](#interacting-with-the-application).

When you add an input, you should see it being processed by the echo server as follows:

```shell
INFO:__main__:Received finish status 200
INFO:__main__:Received advance request data {'metadata': {'msg_sender': '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266', 'epoch_index': 0, 'input_index': 0, 'block_number': 0, 'timestamp': 0}, 'payload': '0x63617274657369'}
INFO:__main__:Adding notice
INFO:__main__:Received notice status 200 body b'{"index":0}'
INFO:__main__:Sending finish
```

Finally, to stop the containers, removing any associated volumes, execute:

```shell
$ docker-compose -f docker-compose.yml -f docker-compose-host.yml down -v
```
