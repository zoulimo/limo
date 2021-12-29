const inquirer = require('inquirer')

const rand = () => Math.floor(Math.random() * 1000000)

module.exports = () => {
  async function run() {

    const value = rand()

    const prompt = await inquirer.prompt([
      {
        type: 'input',
        name: 'room',
        message: `Room number`,
      },
      {
        type: 'input',
        name: 'sign',
        message: `Sign ${value}`,
      }
    ])

    const guest = await web3.eth.personal.ecRecover(`${value}`, prompt.sign)

    const Hotel = artifacts.require('Hotel')
    const hotel = await Hotel.deployed()

    const roomIsBooked = await hotel.roomIsBooked(prompt.room, guest)

    if (roomIsBooked) {
      console.log(`Open room ${prompt.room} for ${guest}.`)

      const roomInfo = await hotel.rooms(prompt.room)
      console.log(`Access until ${new Date(roomInfo.bookedUntil * 1000)}`)
      process.exit()
    } else {
      console.error('Auth failed')
    }
  }

  run().catch(e => {
    console.error(e)
    process.exit(1)
  })
}




// Use web3.eth.personal.sign(msg, account) to sign from console
