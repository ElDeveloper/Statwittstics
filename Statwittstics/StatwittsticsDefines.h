//
//  StatwittsticsDefines.h
//  Statwittstics
//
//  Created by Yoshiki - Vázquez Baeza on 14/04/12.
//  Copyright (c) 2012 Polar Bears Nanotechnology Research ©. All rights reserved.
//

#ifndef Statwittstics_StatwittsticsDefines_h
#define Statwittstics_StatwittsticsDefines_h

#define STATWITTSTICS_VERSION @"1.0"
#define STATWITTSTICS_BUILD   @"XXXX"

#define kDefaultNumberOfTweets 600

#define DEBUG
//#define VERBOSE_DEBUG

#endif

//DG: Imágen de placeholder para la gráfica
//DG: Fondo de el PBTUserView
//DG: Logotipo de la aplicación
//DG: Selección de colores para toda la aplicación

//UX: Revisar si hace falta agregar sonidos

//PBPlot Framework:
//SW: Hacer un objeto gráfica de barras basado en PBPlot
//	+ Graficar número de twitts por hora (distribución)
//	+ Graficar número de twitts por día
//SW: Hacer un annotation que sea un UIPopOverController con una tabla de UITableViewTweetCells

//Statwittstics Framework:
//SW: Controladores para cambiar fácilmente de tipo de visualización (URGENTE)
//SW: Agregar GIDAAlertViews a todos los procesos asíncronos
//SW: Generar PBDataSet de número de twitts por hora 
//SW: Generar PBDataSet de número de twitts por día
//SW: Añadir prueba de Kolmogorov-Smirnov para dos distribuciones
//SW: Comparara dos usuarios en función de sus series de tiempo
//	+ Coeficiente de correlación entre de el número de twitts por día
//	+ Coeficiente de correlación entre la hora a la que dos usuarios twittean
//	+ Comparar distribuciones de twitts por hora
//SW: Limitar el rango de las gráficas
//SW: Añadir ticks-labels y títulos a las gráficas:
//	+ Tweets por día
//	+ Tweets por semana
//	+ Tweets por mes