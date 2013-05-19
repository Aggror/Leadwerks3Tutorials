//
//  Shader.fsh
//  Interpreter
//
//  Created by Josh Klint on 11/5/12.
//  Copyright (c) 2012 Leadwerks Software. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
