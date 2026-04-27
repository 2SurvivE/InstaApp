/***
*    !!!  GEN CODE DO NOT EDIT  !!!
***/
import { getService } from "@kuiklybase/knoi"

export interface CalcService {
            
   add(a: number, b: number): number;

}

export function getCalcService(): CalcService {
   return getService<CalcService>("CalcService")
}

