package org.xtext.gradle.test

import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.xtext.gradle.tasks.XtextEclipsePreferences
import static org.junit.Assert.*
import org.eclipse.core.internal.preferences.EclipsePreferences

class WhenTheEclipsePluginIsApplied {
	@Rule public extension ProjectUnderTest = new ProjectUnderTest

	@Before
	def void setup() {
		buildFile = '''
			buildscript {
				repositories {
					mavenLocal()
					maven {
						url 'https://oss.sonatype.org/content/repositories/snapshots'
					}
					jcenter()
				}
				dependencies {
					classpath 'org.xtext:xtext-gradle-plugin:«System.getProperty("gradle.project.version") ?: 'unspecified'»'
				}
			}
			
			apply plugin: 'java'
			apply plugin: 'eclipse'
			apply plugin: 'org.xtext.builder'
			apply plugin: 'org.xtext.java'
			
			xtext {
				version = '2.9.0-SNAPSHOT'
				languages {
					xtend {
						setup = 'org.eclipse.xtend.core.XtendStandaloneSetup'
						generator {
							outlet {
								producesJava = true
							}
							javaSourceLevel = '1.6'
						}
					}
				}
			}
		'''
		file('src/main/java').mkdirs
		file('src/test/java').mkdirs
	}

	@Test
	def properSettingsAreGenerated() {
		executeTasks("eclipse")
		val prefs = new XtextEclipsePreferences(rootDir, "org.eclipse.xtend.core.Xtend")
		prefs.load
		
		prefs.shouldContain("BuilderConfiguration.is_project_specific", true)
		prefs.shouldContain("ValidatorConfiguration.is_project_specific", true)
		prefs.shouldContain("generateSuppressWarnings", true)
		prefs.shouldContain("generateGeneratedAnnotation", false)
		prefs.shouldContain("includeDateInGenerated", false)
		prefs.shouldContain("useJavaCompilerCompliance", false)
		prefs.shouldContain("targetJavaVersion", "Java6")
		prefs.shouldContain("outlet.DEFAULT_OUTPUT.userOutputPerSourceFolder", true)
		prefs.shouldContain("outlet.DEFAULT_OUTPUT.installDslAsPrimarySource", false)
		prefs.shouldContain("outlet.DEFAULT_OUTPUT.hideLocalSyntheticVariables", true)
		prefs.shouldContain("outlet.DEFAULT_OUTPUT.sourceFolder.src/main/java.directory", "build/xtend/main")
		prefs.shouldContain("outlet.DEFAULT_OUTPUT.sourceFolder.src/test/java.directory", "build/xtend/test")
	}
	
	def shouldContain(EclipsePreferences prefs, String key, Object value) {
		assertEquals(value.toString, prefs.get(key, null))
	}
}
