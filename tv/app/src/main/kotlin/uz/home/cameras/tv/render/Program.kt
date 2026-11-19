package uz.home.cameras.tv.render

import android.opengl.GLES11Ext
import android.opengl.GLES20
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

class Program {
    private val handle: Int
    private val position: Int
    private val texture: Int
    private val matrix: Int
    private val sampler: Int
    private val vertices: FloatBuffer = ByteBuffer.allocateDirect(16 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()

    init {
        val vertex = compile(GLES20.GL_VERTEX_SHADER, VERTEX)
        val fragment = compile(GLES20.GL_FRAGMENT_SHADER, FRAGMENT)
        handle = GLES20.glCreateProgram()
        GLES20.glAttachShader(handle, vertex)
        GLES20.glAttachShader(handle, fragment)
        GLES20.glLinkProgram(handle)
        val status = IntArray(1)
        GLES20.glGetProgramiv(handle, GLES20.GL_LINK_STATUS, status, 0)
        if (status[0] == 0) throw IllegalStateException("link failed: ${GLES20.glGetProgramInfoLog(handle)}")
        GLES20.glDeleteShader(vertex)
        GLES20.glDeleteShader(fragment)
        position = GLES20.glGetAttribLocation(handle, "aPosition")
        texture = GLES20.glGetAttribLocation(handle, "aTexture")
        matrix = GLES20.glGetUniformLocation(handle, "uMatrix")
        sampler = GLES20.glGetUniformLocation(handle, "uSampler")
    }

    fun draw(textureId: Int, transform: FloatArray, quad: FloatArray) {
        GLES20.glUseProgram(handle)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        GLES20.glUniform1i(sampler, 0)
        GLES20.glUniformMatrix4fv(matrix, 1, false, transform, 0)
        vertices.clear()
        vertices.put(quad)
        vertices.position(0)
        GLES20.glVertexAttribPointer(position, 2, GLES20.GL_FLOAT, false, 16, vertices)
        GLES20.glEnableVertexAttribArray(position)
        vertices.position(2)
        GLES20.glVertexAttribPointer(texture, 2, GLES20.GL_FLOAT, false, 16, vertices)
        GLES20.glEnableVertexAttribArray(texture)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        GLES20.glDisableVertexAttribArray(position)
        GLES20.glDisableVertexAttribArray(texture)
    }

    private fun compile(type: Int, source: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, source)
        GLES20.glCompileShader(shader)
        val status = IntArray(1)
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) throw IllegalStateException("compile failed: ${GLES20.glGetShaderInfoLog(shader)}")
        return shader
    }

    companion object {
        private const val VERTEX = """
attribute vec4 aPosition;
attribute vec4 aTexture;
uniform mat4 uMatrix;
varying vec2 vTexture;
void main() {
    gl_Position = aPosition;
    vTexture = (uMatrix * aTexture).xy;
}
"""
        private const val FRAGMENT = """
#extension GL_OES_EGL_image_external : require
precision mediump float;
varying vec2 vTexture;
uniform samplerExternalOES uSampler;
void main() {
    gl_FragColor = texture2D(uSampler, vTexture);
}
"""

        fun newTexture(): Int {
            val ids = IntArray(1)
            GLES20.glGenTextures(1, ids, 0)
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, ids[0])
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
            GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
            return ids[0]
        }

        fun deleteTexture(id: Int) {
            GLES20.glDeleteTextures(1, intArrayOf(id), 0)
        }
    }
}
