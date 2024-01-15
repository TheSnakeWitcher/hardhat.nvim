import fs from "fs"


async function main() {

    const paths = hre.config.paths.deploy
    const deploy_path = paths[0] // NOTE: not working with don't default confis for now

    const files = fs.readdirSync(deploy_path, { recursive: true })

    const tags = await Promise.all( files.map( async (deploy_script) => {
        const mod = await import(`${deploy_path}/${deploy_script}`)
        return mod.default.tags
    }))
    
    return JSON.stringify(tags.flat())
}


main()
.then( response => console.log(response) )
.catch( error => console.log(error) )
