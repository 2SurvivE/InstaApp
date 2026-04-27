import {registerServiceProvider} from '@kuiklybase/knoi'
import { DEBUG, INFO, ERROR , FATAL, WARN} from '../logutils/index'
import {LogServiceProvider} from '../logutils/LogServiceProvider'
import { IServiceProvider } from '../interface/IServiceProvider'

const tag = 'BOOSTRAP'

const ServiceProviderDict: Record<string, IServiceProvider> = {
  'LogService': new LogServiceProvider(),
}

export function init_all_service_provider():void{
  DEBUG(tag, "Start to init service provider")
  try{
    for (const entry of Object.entries(ServiceProviderDict)) {
      const serviceName: string = entry[0]
      const provider: IServiceProvider = entry[1]
      DEBUG(tag,`Try to load ${serviceName} Provider`)
      try{
        registerServiceProvider(serviceName,true,provider)
        DEBUG(tag,`${serviceName} is success to load`)
      }catch (err){
        ERROR(tag,`${serviceName} is not loaded, MSG:${JSON.stringify(err)}`)
      }
    }
  }catch (err){
    ERROR(tag,"Can't init the service provider")
  }

}